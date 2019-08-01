# solr-cloud

ALA solr cloud for swarm mode/kubernetes deployment (custom solr image)

## Intro

This is a custom Solr image for ALA deployment.

There is also a sample deployment of zookeeper + 2 Solr cloud containers

## Running locally

```sh
docker-compose up
```

## TODO

The `solr` folder contains artifacts that maybe should be downloaded at Dockerfile build time.
