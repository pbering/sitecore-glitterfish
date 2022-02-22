# Sitecore Glitterfish

Lightweight Sitecore development environment, only a **single** container needed.

Running Sitecore in a single container is made possible by:

1. Using embedded [SQL Server Express LocalDB](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb?view=sql-server-ver15).
1. Sitecore CLI is supported and enabled by the same approach used in [Sitecore Reforge](https://github.com/pbering/sitecore-reforge).
1. Disabling Solr, Sitecore Content Search and SSL.

## Build (and share image on a private registry)

Run:

1. `$env:REGISTRY="<REGISTRY>/"` to set your target registry so images are tagged accordingly.
1. `docker login` or whatever is needed to authenticate to your target registry.

Then:

1. `docker-compose build`
1. `docker-compose push cm`

## Run/Develop on local Windows machine

1. `docker-compose up -d`
1. `start http://localhost:44090/sitecore/login`

Using Sitecore CLI:

1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm http://localhost:44090 --auth http://localhost:44090 --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b"` (notice that the `--cm` and `--auth` urls points to the same host/port)

## Run/Develop on remote ACI from local Windows/Linux/macOS machine

...

TODO: Developing on ACI?<https://docs.docker.com/cloud/aci-compose-features/#persistent-volumes>

> See the [Deploying Docker containers on Azure](https://docs.docker.com/cloud/aci-integration/) documentation for more information on the Docker + ACI integration.
