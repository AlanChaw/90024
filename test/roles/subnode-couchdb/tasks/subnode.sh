#!/bin/bash

echo "== Set variables =="
export node=45.113.233.252
export user=admin
export password=123456

echo "== Start the containers =="
docker run -d -p 5984:5984 -p 5986:5986 -p 4369:4369 -p 9100:9100 --name=subcouchdb couchdb:2.3.0
sleep 3

# declare -a cont=`docker ps | grep couchdb | cut -f1 -d' '`

declare -a cont=`docker ps -aqf "name=subcouchdb"`

docker exec ${cont} bash -c "echo \"-setcookie couchdb_cluster\" >> /opt/couchdb/etc/vm.args"
docker exec ${cont} bash -c "echo \"-name couchdb@${node}\" >> /opt/couchdb/etc/vm.args"

docker restart subcouchdb
sleep 3
