#!/bin/sh

# wait for zookeeper
if [ ! -z "$ZK_HOST" ]; then
    echo "SOLR-CLOUD ENTRYPOINT: waiting for zookeeper at $ZK_HOST:2181..."
    /opt/wait-for-it.sh -h "$ZK_HOST" -p 2181 --strict -- echo "SOLR-CLOUD ENTRYPOINT: zookeeper is up"
    if [ "$SOLR_HOST" == "solr-1" ]; then
        /opt/upload-collection.sh
        /opt/create-collection.sh &
    fi
fi

# call original entrypoint
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"
