#
# Solr (7.7.1) adapted to ALA
#
FROM solr:7.7.1-alpine

ENV JTS_VERSION 1.16.0
ENV JTS_URL https://nexus.ala.org.au/service/local/repositories/central/content/org/locationtech/jts/jts-core/$JTS_VERSION/jts-core-$JTS_VERSION.jar

# ALA configs
USER root
COPY solr /data/solr/data/
RUN mkdir -p /data/solr/data/bie/conf \
      /data/solr/data/bie/data \
      /data/solr/data/bie-offline/conf \
      /data/solr/data/bie-offline/data \
      /data/solr/data/biocache/conf/ \
      /data/solr/data/biocache/data && \
      chown -R solr:solr /data/solr && \
      apk add --update tini curl
#COPY scripts /opt/docker-solr/scripts

USER solr
RUN wget $JTS_URL -q -O /opt/solr/server/lib/ext/jts-$JTS_VERSION.jar && \
    cp /opt/solr/server/lib/ext/jts-$JTS_VERSION.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/jts-$JTS_VERSION.jar

# copiar scripts
COPY scripts/*.sh /opt/

# ARGs to change default values at build time
ARG ARG_NUM_SHARDS=1
ARG ARG_MAX_SHARDS_PER_NODES=1
ARG ARG_REPLICATION_FACTOR=1

# ENVs to set default values at runtime
ENV SOLR_MAX_SHARDS_PER_NODE=$ARG_MAX_SHARDS_PER_NODES \
    SOLR_NUM_SHARDS=$ARG_NUM_SHARDS \
    SOLR_REPLICATION_FACTOR=$ARG_REPLICATION_FACTOR
#RUN chmod +x /opt/*.sh

EXPOSE 8983

ENTRYPOINT ["tini", "--", "/opt/solr-entrypoint.sh"]
CMD ["solr-foreground"]
