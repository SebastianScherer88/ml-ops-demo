provider "aws" {
  region = local.region
}

provider "aws" {
  region = "eu-west-2"
  alias  = "london"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_availability_zones" "available" {}
# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.london
# }

locals {
  name            = "eks-ray"
  cluster_version = "1.29"
  region          = "eu-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  install_observability_stack = true

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  tags = local.tags
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  cluster_addons = {
    coredns = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
}

################################################################################
# Karpenter
################################################################################

# karpenter controller cant create service linked role for spot, but wont try to do so if the 
# resource already exists before trying to provision spot instances; solution as per
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2565
resource "aws_iam_service_linked_role" "AWSServiceRoleForEC2Spot" {
  aws_service_name = "spot.amazonaws.com"
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  # EKS Fargate currently does not support Pod Identity
  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # # Used to attach additional IAM policies to the Karpenter controller pod
  # iam_role_policies = {
  #   AWSServiceRoleForEC2Spot = "arn:aws:iam::***************:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
  # }

  tags = local.tags
}

module "karpenter_disabled" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  create = false
}

################################################################################
# Kuberay operator/controller chart & manifests
# Required for the ray CRDs
################################################################################

resource "helm_release" "kuberay" {
  name             = "kuberay-operator"
  repository       = "https://ray-project.github.io/kuberay-helm/"
  chart            = "kuberay-operator"
  version          = "1.0.0"
  namespace        = "kuberay"
  create_namespace = true

  # values = [
  #   <<-EOT
  #   image.tag: v1.1.0
  #   env.ENABLE_PROBES_INJECTION: "false"
  #   EOT
  # ]

  depends_on = [
    module.eks
  ]
}

################################################################################
# Karpenter Helm chart & manifests
# Not required; just to demonstrate functionality of the sub-module
################################################################################

resource "helm_release" "karpenter" {
  namespace           = "karpenter"
  create_namespace    = true
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "0.35.1"
  wait                = false

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    EOT
  ]

  depends_on = [
    module.eks
  ]

}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# karpenter nodepool
data "kubectl_file_documents" "karpenter_node_pool" {
  content = file("../manifests/nodepool.yaml")
}

resource "kubectl_manifest" "karpenter_node_pool" {
  for_each  = data.kubectl_file_documents.karpenter_node_pool.manifests
  yaml_body = each.value
  
  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

################################################################################
# Observability (prometheus + grafana) Helm chart & manifests
# Not required; just to demonstrate functionality of the sub-module
################################################################################

resource "random_password" "grafana_admin_password" {

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "helm_release" "observability" {
  count = local.install_observability_stack ? 1 : 0

  namespace        = "observability"
  create_namespace = true
  name             = "observability"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.2.2"

  # includes the grafana permissions tweak to let the ray dashboard acess itss graphs as per
  # https://docs.ray.io/en/latest/cluster/kubernetes/k8s-ecosystem/prometheus-grafana.html#step-2-install-kubernetes-prometheus-stack-via-helm-chart
  values = [
    <<-EOT
    alertmanager:
      enabled: false
    grafana:
      grafana.ini:
        security:
          allow_embedding: true
        auth.anonymous:
          enabled: true
          org_role: Viewer
      enabled: true
      namespaceOverride: observability
      adminPassword: ${random_password.grafana_admin_password.result}
    kubernetesServiceMonitors:
      enabled: true
    kubeApiServer:
      enabled: true
    kubelet:
      enabled: true
    kubeControllerManager:
      enabled: true
    coreDns:
      enabled: true
    kubeDns:
      enabled: false
    kubeEtcd:
      enabled: true
    kubeScheduler:
      enabled: true
    kubeProxy:
      enabled: true
    kubeStateMetrics:
      enabled: true
    kube-state-metrics:
      namespaceOverride: observability
    nodeExporter:
      enabled: true
    prometheus-node-exporter:
      namespaceOverride: observability
    prometheusOperator:
      enabled: true
    thanosRuler:
      enabled: false
    EOT
  ]

  depends_on = [
    module.eks
  ]
}

# example deployment 2
data "kubectl_path_documents" "example_1" {
    pattern = "../manifests/example-1/*.yaml"
}

resource "kubectl_manifest" "example_1" {
  for_each  = data.kubectl_path_documents.example_1.manifests
  yaml_body = each.value
  
  depends_on = [
    helm_release.kuberay,
    helm_release.observability,
  ]
}