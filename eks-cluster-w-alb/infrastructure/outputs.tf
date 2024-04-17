output "eks_cluster_region" {
  value = var.region
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "helm_cert_manager" {
  description = "Install the cert-manager component (required for ALB)  using helm charts when creating the EKS cluster"
  value       = var.helm_cert_manager
}

output "helm_aws_load_balancer_controller" {
  description = "Install the ALB controller component using helm charts when creating the EKS cluster"
  value       = var.helm_aws_load_balancer_controller
}

output "helm_metrics_server" {
  description = "Install the metrics-server component (required for HPA) using helm charts when creating the EKS cluster"
  value       = var.helm_metrics_server
}