data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-eu-west-2a.id,
      aws_subnet.private-eu-west-2b.id,
      aws_subnet.public-eu-west-2a.id,
      aws_subnet.public-eu-west-2b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.amazon-eks-cluster-policy-attach]
}

data "aws_eks_addon_version" "ebs-latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

data "aws_eks_addon_version" "efs-latest" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs-latest.version
}

resource "aws_eks_addon" "aws-efs-csi-driver" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "aws-efs-csi-driver"
  addon_version = data.aws_eks_addon_version.efs-latest.version
}