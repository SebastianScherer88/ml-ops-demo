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
    install            = true
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