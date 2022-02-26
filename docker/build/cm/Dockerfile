# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE
ARG TOOLS_IMAGE
ARG MANAGEMENT_SERVICES_IMAGE
ARG HEADLESS_SERVICES_IMAGE
ARG MSSQL_INIT_IMAGE

FROM ${SOLUTION_IMAGE} AS solution
FROM ${TOOLS_IMAGE} AS tools
FROM ${MANAGEMENT_SERVICES_IMAGE} AS management_services
FROM ${HEADLESS_SERVICES_IMAGE} AS headless_services
FROM ${MSSQL_INIT_IMAGE} AS mssql_init

# ---
FROM ${PARENT_IMAGE} as prepare_sql
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# download LocalDB, SQL tools, SQL CU
RUN New-Item -Path 'C:\\install' -ItemType 'Directory' -Force | Out-Null; `
    & curl.exe -sS -L -o 'C:\\install\\SQL2019-SSEI-Expr.exe' https://go.microsoft.com/fwlink/?LinkID=866658; `
    & curl.exe -sS -L -o 'C:\\install\\DacFramework.msi' https://go.microsoft.com/fwlink/?linkid=2185764;

# ---
FROM ${PARENT_IMAGE}
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# copy install assets
COPY --from=prepare_sql C:\install\ C:\install\

# install SQL Express
COPY SqlConfiguration.ini C:/install/
# TODO: måske er det nok at kalde UDEN config file ala: SQL2019-SSEI-Expr.exe [/ENU] [/Help] [/IAcceptSqlServerLicenseTerms] [/Quiet] [/HideProgressBar] [/Verbose] [/ConfigurationFile=C:\Configuration.ini] [/Action=Install] [/Language=en-US] [/MediaType=Core] [/InstallPath=c:\Program Files\Microsoft SQL Server] [/MediaPath=C:\SetupMedia]
RUN Start-Process "C:\\install\\SQL2019-SSEI-Expr.exe" -ArgumentList '/ACTION=Install', 'CONFIGURATIONFILE=C:\\install\\SqlConfiguration.ini', '/HIDEPROGRESSBAR', '/QUIET', '/IACCEPTSQLSERVERLICENSETERMS' -NoNewWindow -Wait;

# install sqlpackage.exe and add to PATH
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\install\\DacFramework.msi', '/quiet', '/norestart' -NoNewWindow -Wait; `
    SETX PATH ('{0};C:\Program Files\Microsoft SQL Server\160\DAC\bin;' -f ${env:PATH}) | Out-Null;

## TODO: install database some i gamle dage: https://github.com/Sitecore/docker-images/blob/master/build/windows/9.3.x/sitecore-xp-sqldev/Install-Databases.ps1

# cleanup
RUN Remove-Item -Path 'C:\\install' -Force -Recurse; `
    Remove-Item -Path 'C:\\SQL2019' -Force -Recurse

# copy assets from stock mssql-init image
COPY --from=mssql_init C:\resources C:\mssql-init\resources\
COPY --from=mssql_init C:\SetSitecoreAdminPassword.ps1 C:\mssql-init\

# copy scripts
COPY *.ps1 C:/tools/entrypoints/iis/

# copy license.xml
COPY license.xml C:/license/

# set new default entrypoint
ENTRYPOINT [ "powershell", "-Command", "& C:\\tools\\entrypoints\\iis\\Glitterfish.ps1" ]

# continue with CM role...
ARG BUILD_CONFIGURATION='Release'

ENV SITECORE_LICENSE_LOCATION='C:\license\license.xml' `
    Sitecore_ConnectionStrings_Core='Data Source=.\SQLExpress;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Security='Data Source=.\SQLExpress;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Master='Data Source=.\SQLExpress;Integrated Security=true;Initial Catalog=Sitecore.Master;' `
    Sitecore_ConnectionStrings_Web='Data Source=.\SQLExpress;Integrated Security=true;Initial Catalog=Sitecore.Web;' `
    Sitecore_ConnectionStrings_ExperienceForms='Data Source=.\SQLExpress;Integrated Security=true;Initial Catalog=Sitecore.ExperienceForms;' `
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

COPY --from=solution /artifacts/platform/ ./
RUN & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath '.\Web.Common.config.xdt'; `
    & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath ('.\Web.{0}.config.xdt' -f $env:BUILD_CONFIGURATION); `
    Remove-Item -Path '.\\Web.*.xdt' -Force;
