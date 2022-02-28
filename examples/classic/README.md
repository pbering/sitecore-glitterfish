# Classic example

Classic solution with a web application project, compose setup, database persistence, Sitecore CLI serialization.

## Run

1. [optional] `$env:CM_IMAGE="<REGISTRY>/sitecore-glitterfish:latest"` if image is not present locally, set to where you have image stored.
1. [optional] `docker login` or whatever is needed to authenticate to your source registry.
1. `docker-compose up -d`
