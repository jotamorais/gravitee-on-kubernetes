#!/bin/sh
##
# Script to deploy Gravitee.io stack and its dependencies to GKE.
# This is script use local variables set in your terminal. Please, read the [README.md](README.md) for further instructions:

# Deploy MongoDB
MongoDB/GKE/Mongo/scripts/deploy.sh

# Deploy Elasticsearch
Elasticsearch/GKE/Elasticsearch/deploy.sh

# Deploy Gravitee Gateway
./Gravitee/GKE/Gateway/deploy.sh

# Deploy Gravitee Management API
./Gravitee/GKE/Management-API/deploy.sh

# Deploy Gravitee Portal (UI)
./Gravitee/GKE/Portal/deploy.sh
