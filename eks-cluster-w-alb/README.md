# Overview

Taken directly from [the amazing tutorial 112](https://github.com/antonputra/tutorials/tree/main/lessons/112) by [`antonputra`](https://github.com/antonputra) with only minor adjustments.

# Run the stack

1. Create EKS cluster by running `terraform apply` on the `infrastructure` directory. Note that the `10-helm.tf` module deploys the alb controller deployment in the cluster automatically (but does not create a load balancer yet!)
2. Configure `kubectl` with new EKS cluster by runnign `aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_id) --region $(terraform output -raw eks_cluster_region)`
3. Deploy the cluster application + ALB by running `kubectly apply -f` on the `manifests` directory.