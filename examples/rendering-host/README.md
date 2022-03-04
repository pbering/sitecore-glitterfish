# Rendering host example

Solution with a ASP.NET 6.0 rendering host project, compose setup, database persistence, Sitecore CLI serialization.

## Run

1. You need a running Sitecore Glitterfish CM instance, see [examples](../README.md).

<!--

## Run

Clone and open on host or in WSL (adjust `--auth` and `--cm` urls accordingly) and then:

1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm http://host.docker.internal:47080 --auth http://host.docker.internal:47080 --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b" --trace`
1. `dotnet sitecore ser push --publish`

Run on Docker (Linux):

1. `docker-compose up --build` (hot reload works here as well)

Or if you wish to run on host or in WSL:

1. `export DOTNET_USE_POLLING_FILE_WATCHER=true`
1. `./src/ReforgeExample.RenderingHost`
1. `dotnet watch`
-->
