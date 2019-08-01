#!/bin/sh
if [ -z "$ZK_HOST" ]; then
    echo "CREATE-COLLECTION: var ZK_HOST empty, ignoring create-collection"
else
    colecoes='biocache bie-1 bie-2'
    for fn in $colecoes ; do
        /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost zoo -cmd list | grep -q "/collections/$fn"
        if [ $? -eq 0 ]; then
            echo "CREATE-COLLECTION: collection $fn already created, skipping..."
        else
            echo "CREATE-COLLECTION: creating collection $fn..."
            curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=$fn&maxShardsPerNode=$SOLR_MAX_SHARDS_PER_NODE&numShards=$SOLR_NUM_SHARDS&replicationFactor=$SOLR_REPLICATION_FACTOR&collection.configName=$fn"
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
    /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost zoo -cmd list > /tmp/zoolist
    grep -q '"bie-offline":"bie-[0-9]"' /tmp/zoolist
    HAS_BIEOFF_ALIAS=$?
    grep -q '"bie":"bie-[0-9]"' /tmp/zoolist
    HAS_BIE_ALIAS=$?
    if [ $HAS_BIE_ALIAS == 1 ] && [ $HAS_BIEOFF_ALIAS == 1 ]; then
        echo "CREATE-COLLECTION: creating BIE aliases..."
        curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=bie&collections=bie-1"
        curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=bie-offline&collections=bie-2"
        curl "http://localhost:8983/solr/admin/collections?action=LISTALIASES"
    else
        echo "CREATE-COLLECTION: BIE aliases already exists, skipping alias creation"
    fi
fi
