# Sitecore Glitterfish

Lightweight Sitecore XM development environment, only a **single** container needed.

Suitable for:

- Headless projects that needs a simple and light CM.
- Quickly starting new solutions.
- Prototyping modules/code, testing or reproducing issues.
- Running in resource constrained environments such as VM's, older laptops etc.
- Hosting in cloud/VM for developers on non Windows machines.

Jump directly to [getting started](#getting-started), the [examples](#examples) or dig into the [implementation details](#implementation-details).

## Goals

- Provide a Sitecore XM development environment with the **smallest possible footprint** in terms of compute, code and config.
- Easy to run, understand and extend.

### Non-goals

- Production grade images.

## Hosting options

| Option                                                                                             | Notes                                         | SQL data                   | Deployment folder          |
| -------------------------------------------------------------------------------------------------- | --------------------------------------------- | -------------------------- | -------------------------- |
| Windows machine                                                                                    | Very fast                                     | On host                    | On host                    |
| Windows VM cloud/Linux/macOS                                                                       | Fast                                          | VM                  | VM/Share/Azure Files      |
| [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/)         | Fast                                          | Azure Disk                 | Azure Files                |
| [Azure Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/) | Very slow startup\*, fast when warm, auto ssl | Azure Files                | Azure Files                |
| [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/)       | Very slow startup\*, usable when warm         | ~~No Windows support yet~~ | ~~No Windows support yet~~ |
| ~~[Azure Container Apps](https://azure.microsoft.com/en-us/services/container-apps/)~~             | ~~No Windows support yet~~                    | ~~No Windows support yet~~ | ~~No Windows support yet~~ |

> \* First time pulling image from registry in same region can take up to 20 minutes, restarts up to 10 minutes.

## Getting started

First:

1. Place your Sitecore license in `.\docker\build\cm`.

Then build and run from this repo:

1. `docker-compose build`
1. `docker-compose up -d` or as simple as `docker run --rm -d -p 44090:80 -e SITECORE_ADMIN_PASSWORD=b sitecore-glitterfish-cm`
1. `start http://localhost:44090/sitecore/login`

Or build and push to your own **private** registry:

1. `$env:REGISTRY="<REGISTRY>/"` to set your target registry so images are tagged accordingly.
1. `docker login` or whatever is needed to authenticate to your target registry.
1. `docker-compose build`
1. `docker-compose push cm`

### Using the Sitecore CLI

1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm http://localhost:44090 --auth http://localhost:44090 --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b"` (notices that both `--auth` and `--cm` points to the **same** url)
1. Then continue as normally...

## Examples

- [Basic](todo) compose setup with persistence.
- [Classic solution](todo), compose setup, persistance, Sitecore CLI.
- [Rendering host solution](todo), compose setup, persistance, Sitecore CLI, cross platform.
- (Coming soon) Hosting on Azure App Service
- (Coming soon) Hosting on Azure Kubernetes Service.
- (Coming soon) Hosting on Azure Container Instance.

## Implementation details

- Minimal XM with management and headless services installed.
- Default headless app configuration and items, named `DefaultApp`.
- Only _one_ container running, the CM, which has an embedded SQL Server 2019 Express (not usually considered good practice to run multiple processes in the same container, but for _this_ purpose it works quite well).
- Supports the Sitecore CLI _without_ Identity Server, the CM handles the authentication instead.
- Sitecore license file is embedded into image to avoid dealing with volume mounts or Base64/GZipped environment variables.
- Solr/Content Search is disabled.
- No SSL or reverse proxies, just simple port publishing.
- Default environment variables embedded in images, makes consumer compose files simpler while still being overridable at runtime.
- Some less useful features disabled by default such as "WebDAV", "Item Web API", "Device Detection", "Buckets", "Geo IP", "Item Cloning" etc.
