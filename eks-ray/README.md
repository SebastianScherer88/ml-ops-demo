# Kuberay Example

A working KubeRay operator provisioned Ray cluster on EKS with working examples of selected ray libraries (e.g. `core`, `data`,`train`,`serve`).

## Infrastructure

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Then, configure your kubectl to use the newly created EKS cluster:

```bash
# First, make sure you have updated your local kubeconfig
aws eks --region eu-west-2 update-kubeconfig --name eks-ray
```

## Tear Down & Clean-Up

Because Karpenter manages the state of node resources outside of Terraform, Karpenter created resources will need to be de-provisioned first before removing the remaining resources with Terraform.

1. Remove the example deployment created above and any nodes created by Karpenter

```bash
kubectl delete deployment inflate-1
kubectl delete node -l karpenter.sh/provisioner-name=default
```

2. Remove the resources created by Terraform

```bash
terraform destroy
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
