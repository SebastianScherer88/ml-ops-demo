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