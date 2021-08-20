# Custom HPA Deployment on Google Kubernetes Engine

## Create Prometheus Deployment

1] Deploy the prometheus using yaml files.

    kubectl apply -f ./prometheus

## Create Custom Metrics API Deployment

2.1] Generate certificates and secret files

      bash custom-metrics-api/gencerts.sh

2.2] Deploy the custom-metrics-api using yaml files.

      kubectl apply -f ./custom-metrics-api

## Create nginx-prometheus-exporter container image

3.1] Change to the nginx-prometheus-exporter directory.
      
      cd nginx-prometheus-exporter/

3.2] Build and Push the Docker image to Google Container Registry.

      docker build -t gcr.io/<project-id>/nginx-proxy:<tag> .
    
      docker push gcr.io/<project-id>/nginx-proxy:<tag> .

## Create a sample nodejs application

4.1] Change to the sample application directory.

      cd sample-nodejs-app/
    
4.2] Build and Push the Docker image to Google Container Registory.

      docker build -t gcr.io/<project-id>/nodejs:<tag> .
    
      docker push gcr.io/<project-id>/nodejs:<tag>

## Replace the sample nodejs application & nginx-proxy image in the deployment file

5.1] Change to the application manifest directory.

      cd k8s-yamls/

5.2] Update the newly created nodejs & nginx-proxy container image in the pod's container section

For nodejs container,

```
- name: nodejs
  image: gcr.io/<project-id>/nodejs:<tag>
```

For nginx-proxy container,

```
- name: nginx-proxy
  image: gcr.io/<project-id>/nginx-proxy:<tag>
```

## Update the custom hpa target value for the scaling

6] Update the custom hpa target value in order to perform scaling of pods based on request per seconds.

```
metric:
  name: nginx_http_requests
target:
type: AverageValue
  averageValue: "40" #This value can be either in milliseconds or seconds (1s = 1000m). 
```

## Create application deployment

9.1] Apply the kubernetes application directory yaml files.

```
kubectl apply -f ./k8s-yamls
```

9.2] Execute the following commands to check the deployed resources.

```
kubectl get pods -n <namespace> to see all the pods in a namespace
```
```
kubectl get svc -n <namespace> to see all the services in a namespace
```
```
kubectl get hpa -n <namespace> to see all the HPAs in a namespace
```

## Generate the load

10.1] Get the Ingress external endpoint

```
kubectl get ingress -n <namespace> to see all the Ingress in a namespace
```

10.2] Generate the load using Apache benchmarking on the Ingress external endpoint

```
ab -n 10000 -c 100 http://<ingress-external-endpoint-ip>/<route-path>
```

10.3] Check the HPA scaling

```
kubectl get hpa -n <namespace> -w` to see all the HPAs in a namespace
```

