#!/bin/sh
#
# (called from create-collection)
#
if [ ! -f /tmp/zoolist ]; then
    /opt/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost "$ZK_HOST" -cmd list > /tmp/zoolist
fi
grep -q '"bie-offline":"bie-[0-9]"' /tmp/zoolist
HAS_BIEOFF_ALIAS=$?
grep -q '"bie":"bie-[0-9]"' /tmp/zoolist
HAS_BIE_ALIAS=$?
# if no bie alias exists
if [ $HAS_BIE_ALIAS == 1 ] && [ $HAS_BIEOFF_ALIAS == 1 ]; then
    echo "CREATE-ALIASES: creating BIE aliases..."
    curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=bie&collections=bie-1"
    curl "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=bie-offline&collections=bie-2"
    curl "http://localhost:8983/solr/admin/collections?action=LISTALIASES"
else
    echo "CREATE-ALIASES: BIE aliases already exists, skipping alias creation"
fi
