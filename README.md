# Sitecore Glitterfish

Lightweight Sitecore development environment, only a **single** container needed.

Running Sitecore in a single container is made possible by:

1. Using embedded [SQL Server Express LocalDB](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb?view=sql-server-ver15), just a 50 MB install.
1. Sitecore CLI is supported and enabled by the same approach used in [Sitecore Reforge](https://github.com/pbering/sitecore-reforge).
1. Disabling Solr, Sitecore Content Search and SSL.

## Build (and share image on a private registry)

1. `$env:REGISTRY="<REGISTRY>/"` to set your target registry so images are tagged accordingly.
1. `docker login` or whatever is needed to authenticate to your target registry.
1. `docker compose build`
1. `docker compose push cm`

## Run/Develop on local Windows machine

1. `docker compose up -d`
1. `start http://localhost:44090/sitecore/login`

Using Sitecore CLI:

1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm http://localhost:44090 --auth http://localhost:44090 --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b"` (notice that the `--cm` and `--auth` urls points to the same host/port)

## Run/Develop on remote Azure Container Instances from local Windows/Linux/macOS machine

1. `az account set --subscription <SUBSCRIPTION ID>`
1. `az group create --name glitterfish-rg --location westeurope`
1. `az container create --resource-group glitterfish-rg --name glitterfish-cm --os-type Windows --location westeurope --image perberingdevtest.azurecr.io/sitecore-glitterfish-cm:latest --ports 80 --registry-login-server <REGISTRY URL> --registry-username <REGISTRY USERNAME> --registry-password <REGISTRY PASSWORD>`
1. WARNING, TAKES a while... zzzz
1. issues: license, sqlcmd timeouts


## Run/Develop on remote Azure App Service from local Windows/Linux/macOS machine

1. kunne ikke få den til at starte op... fatter det ikke helt....
...

## Run/Develop on remote Azure Container Apps from local Windows/Linux/macOS machine

...

## TODO

- merge/replace with Reforge?
- hmm skulle man overveje at embedded license.xml så man slipper for bøvl med ENV osv?
- Test in ACI
  - <https://docs.microsoft.com/en-us/azure/container-instances/container-instances-multi-container-yaml>
  - MEGA slow, tager 10 min at create...
- volumes til azure file share VIRKER IKKE I WINDOWS!!!
- TODO: fortsæt test i App Service Containers
  - test volume mod azure file share
  - om med embedded license!
- TODO: Test in Container Apps == NOPE == ingen Windows
- TODO: Test Docker Context with ACI == NOPE == ingen Windows
- test på aksdc2 og om Dev virker med file share pvc
- doc at ACI virker til run men IKKE Dev, det samme for de andre metoder...
