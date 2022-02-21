# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE
ARG TOOLS_IMAGE
ARG MANAGEMENT_SERVICES_IMAGE
ARG HEADLESS_SERVICES_IMAGE

FROM ${SOLUTION_IMAGE} AS solution
FROM ${TOOLS_IMAGE} AS tools
FROM ${MANAGEMENT_SERVICES_IMAGE} AS management_services
FROM ${HEADLESS_SERVICES_IMAGE} AS headless_services
FROM ${PARENT_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

####

## TODO: add to new stage
RUN New-Item -Path 'C:\\downloads' -ItemType 'Directory' -Force | Out-Null; `
    & curl.exe -sS -L -o 'C:\\downloads\\SqlLocalDB.msi' https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SqlLocalDB.msi; `
    & curl.exe -sS -L -o 'C:\\downloads\\VC_redist.x64.exe' https://aka.ms/vs/15/release/VC_redist.x64.exe; `
    & curl.exe -sS -L -o 'C:\\downloads\\msodbcsql.msi' https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/17.5.2.1/x64/msodbcsql.msi; `
    & curl.exe -sS -L -o 'C:\\downloads\\MsSqlCmdLnUtils.msi' https://go.microsoft.com/fwlink/?linkid=2142258;

RUN Start-Process 'C:\\downloads\\VC_redist.x64.exe' -ArgumentList '/install', '/passive', '/norestart' -NoNewWindow -Wait;
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\SqlLocalDB.msi', '/quiet', '/norestart', 'IACCEPTSQLLOCALDBLICENSETERMS=YES', '/L C:\localdb-install-log.txt' -NoNewWindow -Wait;
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\msodbcsql.msi', '/quiet', '/norestart', 'IACCEPTMSODBCSQLLICENSETERMS=YES', '/L C:\msodbcsql-install-log.txt' -NoNewWindow -Wait;
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\MsSqlCmdLnUtils.msi', '/quiet', '/norestart', 'IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES', '/L C:\sqlcmd-install-log.txt' -NoNewWindow -Wait;

# RUN SqlLocalDB.exe create 'SC_DB'; `
#     SqlLocalDB.exe share 'SC_DB' 'SC_DB';
    # RUN sqllocaldb.exe share 'MSSQLLocalDB' 'SC_DB'; `
#     sqllocaldb.exe info '.\SC_DB';
# TODO: cannot start, use: https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/sqlclient-support-for-localdb

####

COPY *.mdf C:/inetpub/wwwroot/App_Data/databases/

####


###


ARG BUILD_CONFIGURATION='Release'

ENV SITECORE_LICENSE_LOCATION='C:\license\license.xml' `
    Sitecore_ConnectionStrings_Core='Data Source=(LocalDB)\.;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Security='Data Source=(LocalDB)\.;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Master='Data Source=(LocalDB)\.;Integrated Security=true;Initial Catalog=Sitecore.Master;' `
    Sitecore_ConnectionStrings_Web='Data Source=(LocalDB)\.;Integrated Security=true;Initial Catalog=Sitecore.Web;' `
    Sitecore_ConnectionStrings_ExperienceForms='Data Source=(LocalDB)\.;Integrated Security=true;Initial Catalog=Sitecore.ExperienceForms;' `
    # Sitecore_ConnectionStrings_Core='Server=(LocalDB)\SC_DB;Integrated Security=true;AttachDbFileName=|DataDirectory|\databases\Sitecore.Core_Primary.mdf' `
    # Sitecore_ConnectionStrings_Security='Server=(LocalDB)\SC_DB;Integrated Security=true;AttachDbFileName=|DataDirectory|\Sitecore.Core_Primary.mdf' `
    # Sitecore_ConnectionStrings_Master='Server=(LocalDB)\SC_DB;Integrated Security=true;AttachDbFileName=|DataDirectory|\Sitecore.Master_Primary.mdf' `
    # Sitecore_ConnectionStrings_Web='Server=(LocalDB)\SC_DB;Integrated Security=true;AttachDbFileName=|DataDirectory|\Sitecore.Web_Primary.mdf' `
    # Sitecore_ConnectionStrings_ExperienceForms='Server=(LocalDB)\SC_DB;Integrated Security=true;AttachDbFileName=|DataDirectory|\Sitecore.Experienceforms_Primary.mdf' `
    MEDIA_REQUEST_PROTECTION_SHARED_SECRET='4IDZxWd41uFe4_7drK_pnO9lzDLTgtK-L-gEx3KNLMzuwzEPEJpHX9G4HZtK' `
    Sitecore_AppSettings_Telerik.AsyncUpload.ConfigurationEncryptionKey='QCkAzV6c7q1bXGcdy8uFkJ9JC7Ns0nL00vlAo0eKZ9Mcn-zvbX-LmgdpnCJf' `
    Sitecore_AppSettings_Telerik.Upload.ConfigurationHashKey='gs4gZxwuW1POyjbHrYiL7SlZlM5kDtuNWGo2-XuGWU--cCPyD53keInlnTgarNTVXRwbh4anM5z0bNB6q8dBZBTKvK15yuLKpyjh' `
    Sitecore_AppSettings_Telerik.Web.UI.DialogParametersEncryptionKey='dV-9rMwXv-eiiZzN9XqL1Z6tZvQeYakvIeipnjrAHOhVYFSjtfZnzmOiqHk7iVqkhJpjHZijmjGeljq1Yq6Taj5vEZ6BMU64kCQp' `
    Sitecore_AppSettings_exmEnabled:define='no'

WORKDIR C:\inetpub\wwwroot

COPY --from=tools C:\tools C:\tools
COPY --from=management_services C:\module\cm\content C:\inetpub\wwwroot
COPY --from=headless_services C:\module\cm\content C:\inetpub\wwwroot
COPY --from=headless_services C:\module\tools C:\module\tools
RUN C:\module\tools\Initialize-Content.ps1 -TargetPath C:\inetpub\wwwroot; Remove-Item -Path C:\module -Recurse -Force;

RUN Remove-Item -Path '.\App_Config\Sitecore\ItemWebApi' -Recurse -Force; `
    Remove-Item -Path '.\App_Config\Sitecore\Update' -Recurse -Force; `
    Remove-Item -Path '.\App_Config\Sitecore\DetectionServices.Location' -Recurse -Force; `
    Remove-Item -Path '.\App_Config\Sitecore\DeviceDetection.Client' -Recurse -Force; `
    Remove-Item -Path '.\App_Config\Sitecore\Buckets' -Recurse -Force; `
    Remove-Item -Path '.\App_Config\Sitecore\MVC.DeviceSimulator' -Recurse -Force;

COPY --from=solution /artifacts/platform/ ./
RUN & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath '.\Web.Common.config.xdt'; `
    & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath ('.\Web.{0}.config.xdt' -f $env:BUILD_CONFIGURATION); `
    Remove-Item -Path '.\\Web.*.xdt' -Force;
