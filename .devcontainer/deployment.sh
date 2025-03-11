#!/usr/bin/env bash

NAME=$(whoami)-k8s-otel-o11y   

########################## 
# istio setup
export PATH=$PWD/cluster-manifests/istio-1.22.1/bin:$PATH
istioctl install -f cluster-manifests/istio/istio-operator.yaml --skip-confirmation

sleep 30 

##########################
# update istio ingress
kubectl patch svc -n istio-system istio-ingressgateway --patch "$(cat cluster-manifests/deployment/patch.yaml)"
kubectl delete pod --all -n istio-system

########################## 
# deploy astronomy shop
sed -i "s,NAME_TO_REPLACE,$NAME," cluster-manifests/astronomy-shop/default-values.yaml
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
kubectl create namespace astronomy-shop
kubectl label namespace astronomy-shop istio-injection=enabled
helm install astronomy-shop open-telemetry/opentelemetry-demo --values cluster-manifests/astronomy-shop/default-values.yaml --namespace astronomy-shop --version "0.31.0"