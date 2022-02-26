# Sitecore Glitterfish

Lightweight Sitecore development environment, only a **single** container needed.

Running Sitecore in a single container is made possible by:

1. Using SQL Server 2019 Express embedded into image.
1. Sitecore CLI is supported and enabled by the same approach used in [Sitecore Reforge](https://github.com/pbering/sitecore-reforge).
1. Disabling Solr, Sitecore Content Search and SSL.

## Build (and share image on a private registry)

1. Place your Sitecore license in `.\docker\build\cm`.
1. [optional] `$env:REGISTRY="<REGISTRY>/"` to set your target registry so images are tagged accordingly.
1. `docker-compose build`
1. [optional] `docker login` or whatever is needed to authenticate to your target registry.
1. [optional] `docker-compose push cm`

## Run/Develop on local Windows machine

if you run directly in this repo:

1. `$env:REGISTRY="<REGISTRY>/"` to set your private registry where the image are pushed to.
1. `docker-compose up -d`
1. `start http://localhost:44090/sitecore/login`

### Using Sitecore CLI

1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm http://localhost:44090 --auth http://localhost:44090 --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b"`

### Run/Develop from another Windows machine or repo

Just to test it out: `docker run --rm -d -p 44090:80 -e SITECORE_ADMIN_PASSWORD=b <REGISTRY>/sitecore-glitterfish-cm`

Or using compose with database persistence and a deployment folder (which is watched for file changes as usual):

1. `$env:REGISTRY="<REGISTRY>/"` to set your private registry where the image is pushed to.
1. then the following compose file:

```yml
   services:
   cm:
      image: ${REGISTRY}/sitecore-glitterfish-cm:latest
      ports:
         - "44090:80"
      environment:
         SITECORE_ADMIN_PASSWORD: b
         SITECORE_DEVELOPMENT_PATCHES: DevEnvOn,CustomErrorsOff,DebugOn,RobotDetectionOff
      volumes:
         - .\docker\deploy\platform:C:\deploy:rw
         - .\docker\data\cm\mssql:C:\data:rw
```

## Run/Develop on remote Azure App Service from local Windows/Linux/macOS machine

...

## Run/Develop on remote Azure Kubernetes Service from local Windows/Linux/macOS machine

...

## TODO

- merge/replace with Reforge?
- Test in ACI
  - <https://docs.microsoft.com/en-us/azure/container-instances/container-instances-multi-container-yaml>
  - MEGA slow, tager 10 min at create, nok 15 til pull...
  - volumes til azure file share VIRKER IKKE I WINDOWS (skal i docs)!!!
- TODO: fortsæt test i App Service Containers
  - free ssl virker
  - test volume mod azure file share, virker faktisk!
  - MEGA slow pull, nok 15 min... TEST fra create til HTTP 200
  - Terraform example: <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service#windows_fx_version>
  - hmm CI/CD med hooks til ACR: <https://docs.microsoft.com/en-us/azure/app-service/deploy-ci-cd-custom-container?tabs=private&pivots=container-windows>
- test på aksdc2 og om Dev virker med file share pvc
- doc at ACI virker til run men IKKE Dev, det samme for de andre metoder...
- doc at Docker Context ACI ikke virker med windows...
- doc at Azure Container Apps IKKE viker med windows..
