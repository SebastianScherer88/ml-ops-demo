# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  default = "ml-ops-demo"
}

variable "sub-project" {
  default = "eks-cluster-w-alb"
}

variable "cluster_name" {
  default = "mlops-demo"
}

variable "cluster_version" {
  default = "1.29"
}

variable "cidr_block_private_eu_west_2a" {
  default = "10.0.0.0/19"
}

variable "cidr_block_private_eu_west_2b" {
  default = "10.0.32.0/19"
}

variable "cidr_block_public_eu_west_2a" {
  default = "10.0.64.0/19"
}

variable "cidr_block_public_eu_west_2b" {
  default = "10.0.96.0/19"
}

variable "helm_cert_manager" {
  description = "Helm chart installation specs for the cert-manager component (required for ALB) used during cluster provisioning."
  default = {
    install            = true
    repository         = "https://charts.jetstack.io"
    chart_name         = "cert-manager"
    chart_version      = "v1.4.2"
    chart_release_name = "cert-manager-controller"
    namespace          = "cert-manager"
    create_namespace   = true

    template_values = {
      "image.tag"           = "v1.4.2",
      "installCRDs"         = true,
      "serviceAccount.name" = "cert-manager-controller"
    }
  }
}

variable "helm_aws_load_balancer_controller" {
  description = "Helm chart installation specs for the ALB controller component used during cluster provisioning."
  default = {
    install            = true
    repository         = "https://aws.github.io/eks-charts"
    chart_name         = "aws-load-balancer-controller"
    chart_version      = "1.7.2"
    chart_release_name = "aws-load-balancer-controller"
    namespace          = "kube-system"
    create_namespace   = false

    template_values = {
      "image.tag"           = "v2.7.2",
      "serviceAccount.name" = "aws-load-balancer-controller",
      "enableCertManager"   = true
    }
  }
}

variable "helm_metrics_server" {
  description = "Helm chart installation specs for the metrics-server component (required for HPA) used during cluster provisioning."
  default = {
    install            = false
    repository         = "https://kubernetes-sigs.github.io/metrics-server/"
    chart_name         = "metrics-server"
    chart_version      = "3.12.1"
    chart_release_name = "metrics-server"
    namespace          = "kube-system"
    create_namespace   = false

    template_values = {
      "image.tag"           = "v0.7.1",
      "serviceAccount.name" = "metrics-server",
    }
  }
}

variable "helm_observability" {
  description = "Helm chart installation specs for the prometheus + grafana components used during cluster provisioning."
  default = {
    install            = false
    repository         = "https://prometheus-community.github.io/helm-charts"
    chart_name         = "kube-prometheus-stack"
    chart_version      = "58.1.3"
    chart_release_name = "observability"
    namespace          = "prometheus"
    create_namespace   = true

    template_values = {
      # prometheus namespace
      "prometheus.serviceAccount.name"         = "prometheus",
      "prometheusOperator.serviceAccount.name" = "prometheus-operator",
      "grafana.serviceAccount.name"            = "grafana",
      # kube system namespace
      "kube-state-metrics.namespaceOverride" = "kube-system",
    }
  }
}