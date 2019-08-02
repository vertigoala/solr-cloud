#!/bin/sh
# COLLECTION AND ALIASES MUST BE CREATED AFTER SOLR STARTS (runs in background and waits)
# wait for Solr to be online
/opt/wait-for-it.sh -h localhost -p 8983 --strict -- echo "CREATE-ALIASES: solr is up"
if [ -z "$ZK_HOST" ]; then
    echo "CREATE-COLLECTION: var ZK_HOST empty, ignoring create-collection"
else
    # dumps zoo state to file
    rm -f /tmp/zoolist
    /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost "$ZK_HOST" -cmd list > /tmp/zoolist
    colecoes='biocache bie-1 bie-2'
    for fn in $colecoes ; do
        grep -q "/collections/$fn" /tmp/zoolist
        if [ $? -eq 0 ]; then
            echo "CREATE-COLLECTION: collection $fn already created, skipping..."
        else
            CONFIGNAME="$fn"
            (echo "$fn" | grep -Eq "bie-[0-9]") && CONFIGNAME="bie" # bie fix
            echo "CREATE-COLLECTION: creating collection $fn, configname=$CONFIGNAME..."
            curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=$fn&maxShardsPerNode=$SOLR_MAX_SHARDS_PER_NODE&numShards=$SOLR_NUM_SHARDS&replicationFactor=$SOLR_REPLICATION_FACTOR&collection.configName=$CONFIGNAME"
            echo "CREATE-COLLECTION: collection $fn created"
        fi
    done
    # echo "CREATE-COLLECTION: creating collection biocache..."
    # curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=biocache&maxShardsPerNode=$SOLR_MAX_SHARDS_PER_NODE&numShards=$SOLR_NUM_SHARDS&replicationFactor=$SOLR_REPLICATION_FACTOR&collection.configName=biocache"
    # echo "CREATE-COLLECTION: creating collection bie-1..."
    # curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=bie-1&maxShardsPerNode=$SOLR_MAX_SHARDS_PER_NODE&numShards=$SOLR_NUM_SHARDS&replicationFactor=$SOLR_REPLICATION_FACTOR&collection.configName=bie"
    # echo "CREATE-COLLECTION: creating collection bie-2..."
    # curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=bie-2&maxShardsPerNode=$SOLR_MAX_SHARDS_PER_NODE&numShards=$SOLR_NUM_SHARDS&replicationFactor=$SOLR_REPLICATION_FACTOR&collection.configName=bie"

    # create aliases (only if no alias exists)
    /opt/create-aliases.sh
fi
