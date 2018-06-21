#!/bin/sh
##
# Script to deploy Gravitee management API on an existing Google Cloud cluster.
##
# Set default region/zone
gcloud config set compute/zone $GRAVITEE_DEFAULT_REGION_ZONE

# Update deployment file with the desired quantity of replicas
sed -i -e "s|GRAVITEE_MANAGEMENT_REPLICAS_QTY|${GRAVITEE_MANAGEMENT_REPLICAS_QTY}|g" ./deployment-management-api.yaml

# Deploy...
kubectl create -f deployment-management-api.yaml
kubectl create -f expose-gravitee-management-api.yaml

# Check
kubectl get all
echo

sleep 30 # Waiting service to be expose (GKE Load Balancer might take sometime to do it)

GRAVITEE_MANAGEMENT_HOST=$(kubectl get svc/service-gravitee-management-api -o yaml | grep ip | cut -d':' -f 2 | cut -d' ' -f 2)
GRAVITEE_MANAGEMENT_PORT=$(kubectl get svc/service-gravitee-management-api -o yaml | grep port | cut -d':' -f 2 | cut -d' ' -f 2)
echo "Gravitee Management API is exposed at http://${GRAVITEE_MANAGEMENT_HOST}:${GRAVITEE_MANAGEMENT_PORT}"