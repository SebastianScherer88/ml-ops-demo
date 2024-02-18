Setup steps:

1. Install docker by running `install-docker.sh`
2. Install `kind` by running `install-kind.sh`.
3. Create a `kind` cluster by running `create-kind-cluster.sh`.
3. Follow [the ray service tutoria](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/rayservice.html#example-serve-two-simple-ray-serve-applications-using-rayservice).
    3.1 Install `KubeRay` operator via helm chart by running `install-kuberay-operator.sh`
