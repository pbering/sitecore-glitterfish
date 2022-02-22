# Sitecore LocalDB

...

1. `docker-compose up -d`
1. `dotnet tool restore`
1. `dotnet sitecore login --insecure --cm <http://localhost:44090> --auth <http://localhost:44090> --client-credentials true --allow-write true --client-id "sitecore\admin" --client-secret "b" --trace`
