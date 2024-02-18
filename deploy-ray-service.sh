# Step 3.1: Download `ray_v1alpha1_rayservice.yaml`
curl -LO https://raw.githubusercontent.com/ray-project/kuberay/v1.0.0/ray-operator/config/samples/ray_v1alpha1_rayservice.yaml

# Step 3.2: Create a RayService
kubectl apply -f ray_v1alpha1_rayservice.yaml