# Overview

Taken directly from [the amazing tutorial 112](https://github.com/antonputra/tutorials/tree/main/lessons/112) by [`antonputra`](https://github.com/antonputra) with only minor adjustments, this project creates a minimal EKS cluster, installs a selection of helm charts and creates and tests an internet facing application load balancer with ingress.

# Create EKS cluster

You can configure which K8s components you want to install using terraform's `helm` provisioner during the creation of the cluster - simply toggle the respective variables in the `variables.tf` file.

By default, the following components **will** be installed as helm charts during cluster provisioning:
- [cert-manager](https://cert-manager.io/docs/installation/helm/)
- [aws-load-balancer-controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller)
- [metrics-server](https://artifacthub.io/packages/helm/metrics-server/metrics-server)

Change into the `infrastructure` directory and create the EKS cluster by running 

```bash
terraform apply
``` 

Then, configure `kubectl` with new EKS cluster by running

```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_id) --region $(terraform output -raw eks_cluster_region)
```

# `alb-example`: Create ALB and sample deployment

Change into the `manifests` directory before running the below.

The below manifests will
- create a sample echo server app
- create an ingress that points to the sample app and creates a load balancer

```bash
kubectl apply -f alb-example/namespace.yaml # create namespace
kubectl apply -f alb-example/ # deploy remaining stack
```

To test this service, change into the `code` directory and run

```bash
python test_alb_example.py
```

You should see a response along the lines of

```
ALB URL: http://k8s-albexamp-echoserv-016cf360fa-438199677.eu-west-2.elb.amazonaws.com
Response status code: 200
Response content: 

Hostname: echoserver-6c456d4fcc-drfnz

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.14.2 - lua: 10015

Request Information:
        client_address=10.0.2.125
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://echo.devopsbyexample.io:8080/

Request Headers:
        accept=*/*
        accept-encoding=gzip, deflate
        host=echo.devopsbyexample.io
        user-agent=python-requests/2.31.0
        x-amzn-trace-id=Root=1-662027c0-371c8c920377ff9b0224770e
        x-forwarded-for=34.226.122.148
        x-forwarded-port=80
        x-forwarded-proto=http

Request Body:
        -no body in request-
```

# `ebs-volume`: Create and mount an EBS-backed volume

# `efs-volume`: Create and mount an EFS-backed volume

Run

```bash
kubectl apply -f efs-volume/namespace.yaml
```

```bash
kubectl apply -f efs-volume
```