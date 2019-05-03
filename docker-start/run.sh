echo "== Set variables =="
declare -a nodes=(115.146.92.157 115.146.92.123)
export masternode=115.146.92.157
export size=${#nodes[@]}
export user=admin
export password=123456

echo "== Start the containers =="
docker-compose up -d
sleep 10

echo "== Enable cluster setup =="
for (( i=0; i<${size}; i++ )); do
    curl -X PUT "http://${nodes[${i}]}:5984/_node/_local/_config/admins/${user}" --data "\"${password}\""
    curl -X PUT "http://${user}:${password}@${nodes[${i}]}:5984/_node/couchdb@${nodes[${i}]}/_config/chttpd/bind_address" --data '"0.0.0.0"'
done

echo "== Add nodes to cluster =="
for (( i=0; i<${size}; i++ )); do
    echo "${nodes[${i}]}"
    if [ "${nodes[${i}]}" != "${masternode}" ]; then
        curl -X POST -H 'Content-Type: application/json' http://${user}:${password}@127.0.0.1:5984/_cluster_setup \
            -d "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\", \"username\": \"${user}\", \"password\":\"${password}\", \"port\": 5984, \"node_count\": \"${size}\", \
            \"remote_node\": \"${nodes[${i}]}\", \"remote_current_user\": \"${user}\", \"remote_current_password\": \"${password}\"}"
        curl -X POST -H 'Content-Type: application/json' http://${user}:${password}@127.0.0.1:5984/_cluster_setup \
            -d "{\"action\": \"add_node\", \"host\":\"${nodes[${i}]}\", \"port\": 5984, \"username\": \"${user}\", \"password\":\"${password}\"}"
    fi
done

echo "== Finish cluster =="
curl -X POST -H "Content-Type: application/json" "http://${user}:${password}@127.0.0.1:5984/_cluster_setup" -d '{"action": "finish_cluster"}'

rev=`curl -X GET "http://${masternode}:5986/_nodes/nonode@nohost" --user "${user}:${password}" | sed -e 's/[{}"]//g' | cut -f3 -d:`
curl -X DELETE "http://${masternode}:5986/_nodes/nonode@nohost?rev=${rev}"  --user "${user}:${password}"