Setup steps:

1. Install docker by running `install-docker.sh`
2. Install `kind` by running `install-kind.sh`.
3. Create a `kind` cluster by running `create-kind-cluster.sh`.
4. Install `helm` by running `install-helm.sh`.
5. Follow [the ray service tutoria](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/rayservice.html#example-serve-two-simple-ray-serve-applications-using-rayservice).
    5.1 Deploy the `KubeRay` operator via helm chart by running `deploy-kuberay-operator.sh`
    5.2 Deploy a `RayCluster` CRD by running `deploy-ray-cluster.sh`