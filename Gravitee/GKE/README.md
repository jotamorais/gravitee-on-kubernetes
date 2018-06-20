** Following variables must be filled out before running [deploy.sh](deploy.sh).

# Input variables
## For MongoDB
```shell
$ MONGO_ROOT_USER=main_admin
$ MONGO_ROOT_PASSWORD=abc123
$ MONGO_DEFAULT_REGION_ZONE=us-central1-a
$ MONGO_CLUSTER_NAME=gke-mongodb-cluster
```
## For Elasticsearch
```
$ ELASTIC_DEFAULT_REGION_ZONE=us-east4-a
$ ELASTIC_CLUSTER_NAME=gke-elasticsearch-cluster
```

## For Gravitee
```
$ GRAVITEE_DEFAULT_REGION_ZONE=us-west1-a
$ GRAVITEE_CLUSTER_NAME=apim-gravitee-cluster
$ GRAVITEE_MONGO_DBNAME=gravitee
$ GRAVITEE_MONGO_USERNAME=gravitee
$ GRAVITEE_MONGO_PASSWORD=gravitee123
```

### For Gravitee Gateway
```
$ GRAVITEE_GATEWAY_REPLICAS_QTY=2
```

### For Gravitee Management API
```
$ GRAVITEE_MANAGEMENT_REPLICAS_QTY=1
```

### For Gravitee Portal
```
$ GRAVITEE_PORTAL_REPLICAS_QTY=2
```

# Output variables
## For MongoDB
```shell
echo $MONGO_HOST
echo $MONGO_PORT
```
## For Elasticsearch
```shell
echo $ELASTIC_HOST
echo $ELASTIC_PORT
```

## For Gravitee
### Gravitee Gateway
```shell
echo $GRAVITEE_GATEWAY_HOST
echo $GRAVITEE_GATEWAY_PORT
```

### Gravitee Management API
```shell
echo $GRAVITEE_MANAGEMENT_HOST
echo $GRAVITEE_MANAGEMENT_PORT
```

### Gravitee Portal (UI)
```shell
echo $GRAVITEE_UI_HOST
echo $GRAVITEE_UI_PORT
```
