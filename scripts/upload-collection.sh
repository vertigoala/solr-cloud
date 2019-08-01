#!/bin/ash
if [ -z "$ZK_HOST" ]; then
    echo "UPLOAD-COLLECTION: var ZK_HOST empty, ignoring upload-collection"
else
    colecoes='biocache bie'
    for fn in $colecoes ; do
        /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost zoo -cmd list | grep -q "/configs/$fn"
        if [ $? -eq 0 ]; then
            echo "UPLOAD-COLLECTION: config set $fn already uploaded, skipping..."
        else
            echo "UPLOAD-COLLECTION: uploading config set $fn..."
            /opt/solr/server/scripts/cloud-scripts/zkcli.sh \
                -cmd upconfig \
                -zkhost "$ZK_HOST" \
                -confname $fn \
                -solrhome /data/solr/data \
                -confdir /data/solr/data/$fn/conf/
        fi
        echo "UPLOAD-COLLECTION: config set $fn ready"
    done # for fn
fi
