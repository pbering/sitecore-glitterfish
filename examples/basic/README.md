# Basic example

Basic compose setup for running a CM and database persistence.

## Run

1. [optional] `$env:CM_IMAGE="<REGISTRY>/sitecore-glitterfish:latest"` if image is not present locally, set to where you have image stored.
1. [optional] `docker login` or whatever is needed to authenticate to your source registry.
1. `docker-compose up -d`
