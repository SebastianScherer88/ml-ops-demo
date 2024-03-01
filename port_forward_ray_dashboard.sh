export HEAD_POD=$(kubectl get pods --selector=ray.io/node-type=head -o custom-columns=POD:metadata.name --no-headers)
echo $HEAD_POD

kubectl port-forward $HEAD_POD --address 0.0.0.0 8265:8265
# Check $YOUR_IP:8265 in your browser