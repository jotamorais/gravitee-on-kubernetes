** Following variables must be filled out before running [deploy.sh](deploy.sh).

# Input variables
## MONGO
MONGO_ROOT_USER=main_admin
MONGO_ROOT_PASSWORD=abc123
MONGO_DEFAULT_REGION_ZONE=us-central1-a
MONGO_CLUSTER_NAME=gke-mongodb-cluster

## ELASTIC
ELASTIC_DEFAULT_REGION_ZONE=us-east4-a
ELASTIC_CLUSTER_NAME=gke-elasticsearch-cluster

## GRAVITEE
GRAVITEE_DEFAULT_REGION_ZONE=us-west1-a
GRAVITEE_CLUSTER_NAME=apim-gravitee-cluster
GRAVITEE_MONGO_DBNAME=gravitee
GRAVITEE_MONGO_USERNAME=gravitee
GRAVITEE_MONGO_PASSWORD=gravitee123

### GRAVITEE GATEWAY
GRAVITEE_GATEWAY_REPLICAS_QTY=2

### GRAVITEE MANAGEMENT API
GRAVITEE_MANAGEMENT_REPLICAS_QTY=1

### GRAVITEE_PORTAL
GRAVITEE_PORTAL_REPLICAS_QTY=2

** Upon deployment completion, other variables will be populated (with service hosts and port values generate during the deployment)

# Output variables
## MONGO
echo $MONGO_HOST
echo $MONGO_PORT

## ELASTIC
echo $ELASTIC_HOST
echo $ELASTIC_PORT

## GRAVITEE
### GRAVITEE GATEWAY
echo $GRAVITEE_GATEWAY_HOST
echo $GRAVITEE_GATEWAY_PORT

### GRAVITEE MANAGEMENT API
echo $GRAVITEE_MANAGEMENT_HOST
echo $GRAVITEE_MANAGEMENT_PORT
