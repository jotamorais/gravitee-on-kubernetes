#!/bin/sh
##
# Script to deploy Gravitee UI on an existing Google Cloud cluster.
##
# Set default region/zone
gcloud config set compute/zone $GRAVITEE_DEFAULT_REGION_ZONE

# Update deployment file with the desired quantity of replicas
sed -i -e "s|GRAVITEE_PORTAL_REPLICAS_QTY|${GRAVITEE_PORTAL_REPLICAS_QTY}|g" ./Gravitee/GKE/Portal/deployment-ui.yaml > /tmp/deployment-ui.yaml

# Deploy...
kubectl create -f ./Gravitee/GKE/Portal/ui-config.yaml
kubectl create -f /tmp/deployment-ui.yaml
kubectl create -f ./Gravitee/GKE/Portal/expose-gravitee-ui.yaml

# Check
kubectl get all
echo

sleep 30 # Waiting service to be expose (GKE Load Balancer might take sometime to do it)

GRAVITEE_UI_HOST=$(kubectl get svc/service-gravitee-ui -o yaml | grep ip | cut -d':' -f 2 | cut -d' ' -f 2)
GRAVITEE_UI_PORT=$(kubectl get svc/service-gravitee-ui -o yaml | grep port | cut -d':' -f 2 | cut -d' ' -f 2)
echo "Gravitee Portal (UI) is exposed at http://${GRAVITEE_UI_HOST}:${GRAVITEE_UI_PORT}"

rm -rf /tmp
