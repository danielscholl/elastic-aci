# Instructions

Run local

> Note: WSL & Docker memory issue see [fix](https://stackoverflow.com/questions/69214301/using-docker-desktop-for-windows-how-can-sysctl-parameters-be-configured-to-per/69294687#69294687)
```bash
# Create a network to be used by Elastic Search and Kabana
docker network create elastic

# Create a docker container for Elastic Search
docker run \
    --name elasticsearch \
    --net elastic \
    -d \
    -p 9200:9200 \
    -e discovery.type='single-node' \
    -e xpack.security.enabled=false \
    -e ES_JAVA_OPTS="-Xms1g -Xmx1g"\
    docker.elastic.co/elasticsearch/elasticsearch:8.5.3

# Validate Elastic Running
curl http://localhost:9200

# Start Kibana
docker run \
    --name kibana \
    --net elastic \
    -d \
    -p 5601:5601 \
    docker.elastic.co/kibana/kibana:8.5.3
```

Run Container Instance
```bash
LOCATION="eastus"

dateYMD=$(date +%Y%m%dT%H%M%S%NZ)
GROUP="elastic-search"
NAME="instance-${dateYMD}"
TEMPLATEFILE="main.bicep"
PARAMETERS="@parameters.json"


az deployment sub create \
  --name ${NAME:0:63} \
  --location $LOCATION \
  --template-file $TEMPLATEFILE \
  --parameters $PARAMETERS


$fqdn = az container show -g $resourceGroup -n $containerGroupName --query ipAddress.fqdn -o tsv
```


Sample .env file
```
# Password for the 'elastic' user (at least 6 characters)
ELASTIC_PASSWORD=

# Password for the 'kibana_system' user (at least 6 characters)
KIBANA_PASSWORD=

# Version of Elastic products
STACK_VERSION=8.2.3

# Set the cluster name
CLUSTER_NAME=docker-cluster

# Set to 'basic' or 'trial' to automatically start the 30-day trial
LICENSE=basic
#LICENSE=trial

# Port to expose Elasticsearch HTTP API to the host
ES_PORT=9200
#ES_PORT=127.0.0.1:9200

# Port to expose Kibana to the host
KIBANA_PORT=5601
#KIBANA_PORT=80

# Increase or decrease based on the available host memory (in bytes)
MEM_LIMIT=1073741824

# Project namespace (defaults to the current folder name if not set)
#COMPOSE_PROJECT_NAME=myproject
```


Reference Notes

- https://levelup.gitconnected.com/how-to-run-elasticsearch-8-on-docker-for-local-development-401fd3fff829

- https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-stack-docker.html#get-started-docker-tls
