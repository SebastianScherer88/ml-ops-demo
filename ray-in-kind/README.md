# Setup

The below setup was successfully tested on an AWS EC2 `t2.medium` instance.

1. Install docker by running `install_docker.sh`
2. Install `kind` by running `install_kind.sh`.
3. Install `helm` by running `install_helm.sh`.
4. Create a `kind` cluster by running `create_kind_cluster.sh`.
5. Follow [the `RayService` tutorial](https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/rayservice.html#example-serve-two-simple-ray-serve-applications-using-rayservice).
  - 5.1 Deploy the `KubeRay` operator via helm chart by running `deploy_kuberay_operator.sh`
  - 5.2 Deploy a `RayService` CRD by running `deploy_ray_service.sh`

# Deployment

After completing the setup, you can try running `ray` processes on your local ray cluster. 

1. Run a `RayJob` by running `deploy_ray_job.sh`
2. Run a `RayService` by
  - running `deploy_ray_service.sh` to deploy the CRDs
  - running `test_ray_service.sh` to test the ray service

To check on the cluster state, jobs, serve applications etc run the following dashboard port forwarding in a separate terminal:
`port_forward_ray_dashboard.sh`