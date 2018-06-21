#!/bin/sh
##
# Script to deploy Mongo on top of Kubernetes with a StatefulSet running a Sharded Cluster, to GKE.
# This is script use local variables set in your terminal. Before running this, make sure to fill out following variables:
# =========================================================
# MONGO_ROOT_USER
# MONGO_ROOT_PASSWORD
# MONGO_DEFAULT_REGION_ZONE
# MONGO_CLUSTER_NAME
# GRAVITEE_MONGO_DBNAME
# GRAVITEE_MONGO_USERNAME
# GRAVITEE_MONGO_PASSWORD
# =========================================================
# Example:
# $ export MONGO_ROOT_USER=main_admin
# $ export MONGO_ROOT_PASSWORD=abc123
# $ export MONGO_DEFAULT_REGION_ZONE=us-central1-a
# $ export MONGO_CLUSTER_NAME=gke-mongodb-cluster
# $ export GRAVITEE_MONGO_DBNAME=gravitee
# $ export GRAVITEE_MONGO_USERNAME=gravitee
# $ export GRAVITEE_MONGO_PASSWORD=gravitee123
##

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo Parent path is "${parent_path}"
cd "${parent_path}"

echo Setting default region to "${MONGO_DEFAULT_REGION_ZONE}"

# Set default region/zone
gcloud config set compute/zone $MONGO_DEFAULT_REGION_ZONE

# Create new GKE Kubernetes cluster (using host node VM images based on Ubuntu
# rather than default ChromiumOS & also use slightly larger VMs than default)
echo "Creating GKE Cluster"
gcloud container clusters create "${MONGO_CLUSTER_NAME}" --image-type=UBUNTU --machine-type=n1-standard-2

# Switch context to the newly created cluster
kubectl config use-context "${MONGO_CLUSTER_NAME}"

# Configure host VM using daemonset to disable hugepages
echo "Deploying GKE Daemon Set"
kubectl apply -f ./MongoDB/GKE/Mongo/resources/hostvm-node-configurer-daemonset.yaml


# Define storage class for dynamically generated persistent volumes
# NOT USED IN THIS EXAMPLE AS EXPLICITLY CREATING DISKS FOR USE BY PERSISTENT
# VOLUMES, HENCE COMMENTED OUT BELOW
#kubectl apply -f ../resources/gce-ssd-storageclass.yaml

# Register GCE Fast SSD persistent disks and then create the persistent disks
echo "Creating GCE disks"
for i in 1 2 3
do
    # 4GB disks    
    gcloud compute disks create --size 4GB --type pd-ssd pd-ssd-disk-4g-$i
done
for i in 1 2 3 4 5 6 7 8 9
do
    # 8 GB disks
    gcloud compute disks create --size 8GB --type pd-ssd pd-ssd-disk-8g-$i
done
sleep 3


# Create persistent volumes using disks that were created above
echo "Creating GKE Persistent Volumes"
for i in 1 2 3
do
    # Replace text stating volume number + size of disk (set to 4)
    sed -e "s/INST/${i}/g; s/SIZE/4/g" ./MongoDB/GKE/Mongo/resources/xfs-gce-ssd-persistentvolume.yaml > /tmp/xfs-gce-ssd-persistentvolume.yaml
    kubectl apply -f /tmp/xfs-gce-ssd-persistentvolume.yaml
done
for i in 1 2 3 4 5 6 7 8 9
do
    # Replace text stating volume number + size of disk (set to 8)
    sed -e "s/INST/${i}/g; s/SIZE/8/g" ./MongoDB/GKE/Mongo/resources/xfs-gce-ssd-persistentvolume.yaml > /tmp/xfs-gce-ssd-persistentvolume.yaml
    kubectl apply -f /tmp/xfs-gce-ssd-persistentvolume.yaml
done
rm /tmp/xfs-gce-ssd-persistentvolume.yaml
sleep 3


# Create keyfile for the MongoDB cluster as a Kubernetes shared secret
TMPFILE=$(mktemp)
/usr/bin/openssl rand -base64 741 > $TMPFILE
kubectl create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=$TMPFILE
rm $TMPFILE


# Deploy a MongoDB ConfigDB Service ("Config Server Replica Set") using a Kubernetes StatefulSet
echo "Deploying GKE StatefulSet & Service for MongoDB Config Server Replica Set"
kubectl apply -f ./MongoDB/GKE/Mongo/resources/mongodb-configdb-service.yaml


# Deploy each MongoDB Shard Service using a Kubernetes StatefulSet
echo "Deploying GKE StatefulSet & Service for each MongoDB Shard Replica Set"
sed -e 's/shardX/shard1/g; s/ShardX/Shard1/g' ./MongoDB/GKE/Mongo/resources/mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
sed -e 's/shardX/shard2/g; s/ShardX/Shard2/g' ./MongoDB/GKE/Mongo/resources/mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
sed -e 's/shardX/shard3/g; s/ShardX/Shard3/g' ./MongoDB/GKE/Mongo/resources/mongodb-maindb-service.yaml > /tmp/mongodb-maindb-service.yaml
kubectl apply -f /tmp/mongodb-maindb-service.yaml
rm /tmp/mongodb-maindb-service.yaml


# Deploy some Mongos Routers using a Kubernetes StatefulSet
echo "Deploying GKE Deployment & Service for some Mongos Routers"
kubectl apply -f ./MongoDB/GKE/Mongo/resources/mongodb-mongos-service.yaml

# Wait until the final mongod of each Shard + the ConfigDB has started properly
echo
echo "Waiting for all the shards and configdb containers to come up (`date`)..."
echo " (IGNORE any reported not found & connection errors)"
sleep 30
echo -n "  "
until kubectl --v=0 exec mongod-configdb-2 -c mongod-configdb-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 5
    echo -n "  "
done
echo -n "  "
until kubectl --v=0 exec mongod-shard1-2 -c mongod-shard1-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 5
    echo -n "  "
done
echo -n "  "
until kubectl --v=0 exec mongod-shard2-2 -c mongod-shard2-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 5
    echo -n "  "
done
echo -n "  "
until kubectl --v=0 exec mongod-shard3-2 -c mongod-shard3-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 5
    echo -n "  "
done
echo "...shards & configdb containers are now running (`date`)"
echo


# Initialise the Config Server Replica Set and each Shard Replica Set
echo "Configuring Config Server's & each Shard's Replica Sets"
kubectl exec mongod-configdb-0 -c mongod-configdb-container -- mongo --eval 'rs.initiate({_id: "ConfigDBRepSet", version: 1, members: [ {_id: 0, host: "mongod-configdb-0.mongodb-configdb-service.default.svc.cluster.local:27017"}, {_id: 1, host: "mongod-configdb-1.mongodb-configdb-service.default.svc.cluster.local:27017"}, {_id: 2, host: "mongod-configdb-2.mongodb-configdb-service.default.svc.cluster.local:27017"} ]});'
kubectl exec mongod-shard1-0 -c mongod-shard1-container -- mongo --eval 'rs.initiate({_id: "Shard1RepSet", version: 1, members: [ {_id: 0, host: "mongod-shard1-0.mongodb-shard1-service.default.svc.cluster.local:27017"}, {_id: 1, host: "mongod-shard1-1.mongodb-shard1-service.default.svc.cluster.local:27017"}, {_id: 2, host: "mongod-shard1-2.mongodb-shard1-service.default.svc.cluster.local:27017"} ]});'
kubectl exec mongod-shard2-0 -c mongod-shard2-container -- mongo --eval 'rs.initiate({_id: "Shard2RepSet", version: 1, members: [ {_id: 0, host: "mongod-shard2-0.mongodb-shard2-service.default.svc.cluster.local:27017"}, {_id: 1, host: "mongod-shard2-1.mongodb-shard2-service.default.svc.cluster.local:27017"}, {_id: 2, host: "mongod-shard2-2.mongodb-shard2-service.default.svc.cluster.local:27017"} ]});'
kubectl exec mongod-shard3-0 -c mongod-shard3-container -- mongo --eval 'rs.initiate({_id: "Shard3RepSet", version: 1, members: [ {_id: 0, host: "mongod-shard3-0.mongodb-shard3-service.default.svc.cluster.local:27017"}, {_id: 1, host: "mongod-shard3-1.mongodb-shard3-service.default.svc.cluster.local:27017"}, {_id: 2, host: "mongod-shard3-2.mongodb-shard3-service.default.svc.cluster.local:27017"} ]});'
echo


# Wait for each MongoDB Shard's Replica Set + the ConfigDB Replica Set to each have a primary ready
echo "Waiting for all the MongoDB ConfigDB & Shards Replica Sets to initialise..."
kubectl exec mongod-configdb-0 -c mongod-configdb-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
kubectl exec mongod-shard1-0 -c mongod-shard1-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
kubectl exec mongod-shard2-0 -c mongod-shard2-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
kubectl exec mongod-shard3-0 -c mongod-shard3-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
sleep 2 # Just a little more sleep to ensure everything is ready!
echo "...initialisation of the MongoDB Replica Sets completed"
echo


# Wait for the mongos to have started properly
echo "Waiting for the first mongos to come up (`date`)..."
echo " (IGNORE any reported not found & connection errors)"
echo -n "  "
until kubectl --v=0 exec mongos-router-0 -c mongos-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 2
    echo -n "  "
done
echo "...first mongos is now running (`date`)"
echo


# Add Shards to the Configdb
echo "Configuring ConfigDB to be aware of the 3 Shards"
kubectl exec mongos-router-0 -c mongos-container -- mongo --eval 'sh.addShard("Shard1RepSet/mongod-shard1-0.mongodb-shard1-service.default.svc.cluster.local:27017");'
kubectl exec mongos-router-0 -c mongos-container -- mongo --eval 'sh.addShard("Shard2RepSet/mongod-shard2-0.mongodb-shard2-service.default.svc.cluster.local:27017");'
kubectl exec mongos-router-0 -c mongos-container -- mongo --eval 'sh.addShard("Shard3RepSet/mongod-shard3-0.mongodb-shard3-service.default.svc.cluster.local:27017");'
sleep 3

# Look up and replace placeholders with variable values
sed -i -e "s|MONGO_ROOT_USER|${MONGO_ROOT_USER:-default main_admin}|g" ./MongoDB/GKE/Mongo/scripts/add-gravitee-mongo-user.sh > /tmp/add-gravitee-mongo-user.sh
sed -i -e "s|MONGO_ROOT_PASSWORD|${MONGO_ROOT_PASSWORD:-default abc123}|g" ./MongoDB/GKE/Mongo/scripts/add-gravitee-mongo-user.sh > /tmp/add-gravitee-mongo-user.sh
sed -i -e "s|GRAVITEE_MONGO_DBNAME|${GRAVITEE_MONGO_DBNAME:-default gravitee}|g" ./MongoDB/GKE/Mongo/scripts/add-gravitee-mongo-user.sh > /tmp/add-gravitee-mongo-user.sh
sed -i -e "s|GRAVITEE_MONGO_USERNAME|${GRAVITEE_MONGO_USERNAME:-default gravitee}|g" ./MongoDB/GKE/Mongo/scripts/add-gravitee-mongo-user.sh > /tmp/add-gravitee-mongo-user.sh
sed -i -e "s|GRAVITEE_MONGO_PASSWORD|${GRAVITEE_MONGO_PASSWORD:-default gravitee123}|g" ./MongoDB/GKE/Mongo/scripts/add-gravitee-mongo-user.sh > /tmp/add-gravitee-mongo-user.sh

# Create the Admin User (this will automatically disable the localhost exception)
echo "Creating user: 'main_admin'"
kubectl exec mongos-router-0 -c mongos-container -- mongo --eval 'db.getSiblingDB("admin").createUser({user:"'"${MONGO_ROOT_USER}"'",pwd:"'"${MONGO_ROOT_PASSWORD}"'",roles:[{role:"root",db:"admin"}]});quit();'

echo "Creating user: '${GRAVITEE_MONGO_USERNAME}'"
kubectl exec -it mongos-router-0 -c mongos-container bash < /tmp/add-gravitee-mongo-user.sh
rm /tmp/add-gravitee-mongo-user.sh
echo

# Expose MongoDB using LoadBalancer
echo "Exposing MongoDB"
kubectl apply -f ./MongoDB/GKE/Mongo/resources/mongo-expose-service.yaml
sleep 30 # Waiting service to be expose (GKE Load Balancer might take sometime to do it)


# Print Summary State
kubectl get persistentvolumes
echo
kubectl get all 
echo
sleep 30 # Waiting a little bit more to get the externail Load Balancer IP


export MONGO_HOST=$(kubectl get svc/mongo -o yaml | grep ip | cut -d':' -f 2 | cut -d',' -f 3 | awk NF)
export MONGO_PORT=$(kubectl get svc/mongo -o yaml | grep port | cut -d':' -f 2 | cut -d',' -f 3 | awk NF)
echo "MongoDB is exposed at http://${MONGO_HOST}:${MONGO_PORT}"
