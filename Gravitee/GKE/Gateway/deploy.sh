#!/bin/sh
##
# Script to deploy a Kubernetes cluster with pods and services for Gravitee gateway, management API and UI.
# This is script uses local variables set in your terminal. Before running this, make sure to fill out following variables:
# =========================================================
# MONGO_ROOT_USER
# MONGO_ROOT_PASSWORD
# MONGO_DEFAULT_REGION_ZONE
# MONGO_CLUSTER_NAME
# ELASTIC_CLUSTER_NAME
# GRAVITEE_DEFAULT_REGION_ZONE
# GRAVITEE_CLUSTER_NAME
# GRAVITEE_MONGO_DBNAME
# GRAVITEE_MONGO_USERNAME
# GRAVITEE_MONGO_PASSWORD
# =========================================================
# Example:
# $ MONGO_ROOT_USER=main_admin
# $ MONGO_ROOT_PASSWORD=abc123
# $ MONGO_DEFAULT_REGION_ZONE=us-central1-a
# $ MONGO_CLUSTER_NAME=gke-mongodb-cluster
# $ ELASTIC_CLUSTER_NAME=gke-elastic-cluster
# $ GRAVITEE_DEFAULT_REGION_ZONE=us-west1-a
# $ GRAVITEE_CLUSTER_NAME=apim-gravitee-cluster
# $ GRAVITEE_MONGO_DBNAME=gravitee
# $ GRAVITEE_MONGO_USERNAME=gravitee
# $ GRAVITEE_MONGO_PASSWORD=gravitee123
##

# Update secrets and config files with values from user input (terminal variables)
# MongoDB
sed -i -e "s|GRAVITEE_MONGO_USERNAME|${GRAVITEE_MONGO_USERNAME:-default gravitee}|g" \ 
-e "s|GRAVITEE_MONGO_PASSWORD|${GRAVITEE_MONGO_PASSWORD:-default gravitee123}|g" \ 
-e "s|GRAVITEE_MONGO_DBNAME|${GRAVITEE_MONGO_DBNAME:-default gravitee}|g" \ 
-e "s|GRAVITEE_MONGO_HOST|${MONGO_HOST}|g" \ 
-e "s|GRAVITEE_MONGO_PORT|${MONGO_PORT:-default 27017}|g" \ 
./mongo-secret.yaml

# Elasticsearch
sed -i -e "s|GRAVITEE_ELASTIC_HOST|${ELASTIC_HOST}|g" \ 
-e "s|GRAVITEE_ELASTIC_PORT|${ELASTIC_PORT:-default 9200}|g" \ 
./elastic-search-secret.yaml

# Update Gateway replicas quantity (default is 2)
sed -i -e "s|GRAVITEE_GATEWAY_REPLICAS_QTY|${GRAVITEE_GATEWAY_REPLICAS_QTY:-default 2}|g" ./deployment-gateway.yaml

# Set default region/zone
gcloud config set compute/zone $GRAVITEE_DEFAULT_REGION_ZONE

# Create new GKE Kubernetes cluster
gcloud container clusters create $GRAVITEE_CLUSTER_NAME --image-type=UBUNTU --machine-type=n1-standard-1

# Switch context to the newly created cluster
kubectl config use-context $GRAVITEE_CLUSTER_NAME

# Deploy...
kubectl create -f ./mongo-secret.yaml
kubectl create -f ./elastic-search-secret.yaml
kubectl create -f ./deployment-gateway.yaml
kubectl create -f ./expose-gravitee-gateway.yaml

# Export IP address of exposed Gravitee Gateway service
GRAVITEE_GATEWAY_HOST=$(kubectl get svc/service-gravitee-gateway -o yaml | grep ip | cut -d':' -f 2 | cut -d' ' -f 2)
GRAVITEE_GATEWAY_PORT=$(kubectl get svc/service-gravitee-gateway -o yaml | grep port | cut -d':' -f 2 | cut -d' ' -f 2)

# Check
kubectl get all
echo

sleep 30 # Waiting service to be expose (GKE Load Balancer might take sometime to do it)
echo "Gateway is exposed at http://${GRAVITEE_GATEWAY_HOST}:${GRAVITEE_GATEWAY_PORT}"