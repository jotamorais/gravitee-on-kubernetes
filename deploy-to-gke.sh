#!/bin/bash
##
# Script to deploy Gravitee.io stack and its dependencies to GKE.

echo "This is script uses local variables set in your terminal. Please, read the [README.md](README.md) for further instructions:"
echo =============================================================================================================================
echo

echo "Please, provide variable values for MongoDB..."
read -p 'MONGO_ROOT_USER: ' mongo_root_user_var
export MONGO_ROOT_USER=$mongo_root_user_var

echo "MONGO_ROOT_PASSWORD: "
stty -echo
read mongo_root_password_var
stty echo
printf "\n"
export MONGO_ROOT_PASSWORD=$mongo_root_password_var

read -p 'MONGO_DEFAULT_REGION_ZONE: ' mongo_default_region_zone_var
export MONGO_DEFAULT_REGION_ZONE=$mongo_default_region_zone_var

read -p 'MONGO_CLUSTER_NAME: ' mongo_cluster_name_var
export MONGO_CLUSTER_NAME=$mongo_cluster_name_var
echo

echo =============================================================================================================================
echo "Please, provide variable values for Elasticsearch..."
read -p 'ELASTIC_DEFAULT_REGION_ZONE: ' elastic_default_region_zone_var
export ELASTIC_DEFAULT_REGION_ZONE=$elastic_default_region_zone_var

read -p 'ELASTIC_CLUSTER_NAME: ' elastic_cluster_name_var
export ELASTIC_CLUSTER_NAME=$elastic_cluster_name_var
echo

echo =============================================================================================================================
echo "Please, provide variable values for Gravitee..."
read -p 'GRAVITEE_DEFAULT_REGION_ZONE: ' gravitee_default_region_zone_var
export GRAVITEE_DEFAULT_REGION_ZONE=$gravitee_default_region_zone_var

read -p 'GRAVITEE_CLUSTER_NAME: ' gravitee_cluster_name_var
export GRAVITEE_CLUSTER_NAME=$gravitee_cluster_name_var

read -p 'GRAVITEE_MONGO_DBNAME: ' gravitee_mongo_dbname_var
export GRAVITEE_MONGO_DBNAME=$gravitee_mongo_dbname_var

read -p 'GRAVITEE_MONGO_USERNAME: ' gravitee_mongo_username_var
export GRAVITEE_MONGO_USERNAME=$gravitee_mongo_username_var

echo "GRAVITEE_MONGO_PASSWORD: "
stty -echo
read gravitee_mongo_password_var
stty echo
printf "\n"
export GRAVITEE_MONGO_PASSWORD=$gravitee_mongo_password_var
echo

echo =============================================================================================================================
echo "Please, provide variable values for Gravitee Gateway..."
read -p 'GRAVITEE_GATEWAY_REPLICAS_QTY: ' gravitee_gateway_replicas_qty_var
export GRAVITEE_GATEWAY_REPLICAS_QTY=$gravitee_gateway_replicas_qty_var

echo

echo =============================================================================================================================
echo "Please, provide variable values for Gravitee Management API..."
read -p 'GRAVITEE_MANAGEMENT_REPLICAS_QTY: ' gravitee_management_replicas_qty_var
export GRAVITEE_MANAGEMENT_REPLICAS_QTY=$gravitee_management_replicas_qty_var
echo

echo =============================================================================================================================
echo "Please, provide variable values for Gravitee Portal..."
read -p 'GRAVITEE_PORTAL_REPLICAS_QTY: ' gravitee_portal_replicas_qty_var
export GRAVITEE_PORTAL_REPLICAS_QTY=$gravitee_portal_replicas_qty_var
echo

GREEN='\033[0;32m'

echo "${GREEN}============================================================================================================================="
echo "Thank you. Variables set are:"
echo "For MongoDB"
echo "export MONGO_ROOT_USER=${MONGO_ROOT_USER}"
echo "export MONGO_ROOT_PASSWORD=********"
echo "export MONGO_DEFAULT_REGION_ZONE=${MONGO_DEFAULT_REGION_ZONE}"
echo "export MONGO_CLUSTER_NAME=${MONGO_CLUSTER_NAME}"
echo
echo "For Elasticsearch"
echo "export ELASTIC_DEFAULT_REGION_ZONE=${ELASTIC_DEFAULT_REGION_ZONE}"
echo "export ELASTIC_CLUSTER_NAME=${ELASTIC_CLUSTER_NAME}"
echo
echo "For Gravitee"
echo "export GRAVITEE_DEFAULT_REGION_ZONE=${GRAVITEE_DEFAULT_REGION_ZONE}"
echo "export GRAVITEE_CLUSTER_NAME=${GRAVITEE_CLUSTER_NAME}"
echo "export GRAVITEE_MONGO_DBNAME=${GRAVITEE_MONGO_DBNAME}"
echo "export GRAVITEE_MONGO_USERNAME=${GRAVITEE_MONGO_USERNAME}"
echo "export GRAVITEE_MONGO_PASSWORD=********"
echo
echo "For Gravitee Gateway"
echo "export GRAVITEE_GATEWAY_REPLICAS_QTY=${GRAVITEE_GATEWAY_REPLICAS_QTY}"
echo
echo "For Gravitee Management API"
echo "export GRAVITEE_MANAGEMENT_REPLICAS_QTY=${GRAVITEE_MANAGEMENT_REPLICAS_QTY}"
echo
echo "For Gravitee Portal"
echo "export GRAVITEE_PORTAL_REPLICAS_QTY=${GRAVITEE_PORTAL_REPLICAS_QTY}"
sleep 30

echo
echo
echo

# Deploy MongoDB
MongoDB/GKE/Mongo/scripts/deploy.sh

# Deploy Elasticsearch
#Elasticsearch/GKE/Elasticsearch/deploy.sh

# Deploy Gravitee Gateway
#./Gravitee/GKE/Gateway/deploy.sh

# Deploy Gravitee Management API
#./Gravitee/GKE/Management-API/deploy.sh

# Deploy Gravitee Portal (UI)
#./Gravitee/GKE/Portal/deploy.sh
