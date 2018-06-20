#!/usr/bin/env bash
##
# Script to deploy a Elasticsearch on GKE (Google Kubernetes Engine)
# This is script uses local variables set in your terminal. Before running this, make sure to fill out following variables:
# =========================================================
# ELASTIC_DEFAULT_REGION_ZONE
# ELASTIC_CLUSTER_NAME
# =========================================================
# Example:
# $ ELASTIC_DEFAULT_REGION_ZONE=us-east4-a
# $ ELASTIC_CLUSTER_NAME=gke-elasticsearch-cluster
##

# Set default region/zone
gcloud config set compute/zone $ELASTIC_DEFAULT_REGION_ZONE

# Create new GKE Kubernetes cluster
gcloud container clusters create $ELASTIC_CLUSTER_NAME --machine-type="n1-standard-2"

# Deploy...
kubectl create -f es-discovery-svc.yaml
kubectl create -f es-svc.yaml
kubectl create -f es-master.yaml
kubectl rollout status -f es-master.yaml
kubectl create -f es-client.yaml
kubectl rollout status -f es-client.yaml
kubectl create -f es-data.yaml
kubectl rollout status -f es-data.yaml

# Checks status
kubectl get svc,deployment,pods -l component=elasticsearch
kubectl get svc elasticsearch

# Deploy Kibana
kubectl create -f kibana.yaml
kubectl create -f kibana-svc.yaml

sleep 30 # Waiting service to be expose (GKE Load Balancer might take sometime to do it)

ELASTIC_HOST=$(kubectl get svc/elasticsearch -o yaml | grep ip | cut -d':' -f 2 | cut -d' ' -f 2)
ELASTIC_PORT=$(kubectl get svc/elasticsearch -o yaml | grep port | cut -d':' -f 2 | cut -d' ' -f 2)
echo "MongoDB is exposed at http://${ELASTIC_HOST}:${ELASTIC_PORT}"