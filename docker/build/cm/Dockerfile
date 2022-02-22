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

###

## TODO: add to new stage for downloads?
RUN New-Item -Path 'C:\\downloads' -ItemType 'Directory' -Force | Out-Null; `
    & curl.exe -sS -L -o 'C:\\downloads\\SQL2019-SSEI-Expr.exe' https://go.microsoft.com/fwlink/?LinkID=866658; `
    & curl.exe -sS -L -o 'C:\\downloads\\VC_redist.x64.exe' https://aka.ms/vs/17/release/vc_redist.x64.exe; `
    & curl.exe -sS -L -o 'C:\\downloads\\msodbcsql.msi' https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/17.5.2.1/x64/msodbcsql.msi; `
    & curl.exe -sS -L -o 'C:\\downloads\\MsSqlCmdLnUtils.msi' https://go.microsoft.com/fwlink/?linkid=2142258; `
    & curl.exe -sS -L -o 'C:\\downloads\\SQLServer2019-CU-x64.exe' https://download.microsoft.com/download/6/e/7/6e72dddf-dfa4-4889-bc3d-e5d3a0fd11ce/SQLServer2019-KB5008996-x64.exe; `
    & curl.exe -sS -L -o 'C:\\downloads\\DacFramework.msi' https://go.microsoft.com/fwlink/?linkid=2185764

# install LocalDB
RUN Start-Process 'C:\\downloads\\VC_redist.x64.exe' -ArgumentList '/install', '/passive', '/norestart' -NoNewWindow -Wait; `
    Start-Process 'C:\\downloads\\SQL2019-SSEI-Expr.exe' -ArgumentList '/Action=Download', '/MediaType=LocalDB', '/Quiet' -NoNewWindow -Wait; `
    Start-Process msiexec.exe -ArgumentList '/i',  (Join-Path $env:USERPROFILE '\Downloads\en-US\SqlLocalDB.msi'), '/quiet', '/norestart', 'IACCEPTSQLLOCALDBLICENSETERMS=YES' -NoNewWindow -Wait;

# install sqlcmd.exe
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\msodbcsql.msi', '/quiet', '/norestart', 'IACCEPTMSODBCSQLLICENSETERMS=YES' -NoNewWindow -Wait; `
    Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\MsSqlCmdLnUtils.msi', '/quiet', '/norestart', 'IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES' -NoNewWindow -Wait;

# install sqlpackage.exe
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\\downloads\\DacFramework.msi', '/quiet', '/norestart' -NoNewWindow -Wait; `
    SETX PATH ('{0};C:\Program Files\Microsoft SQL Server\160\DAC\bin;' -f ${env:PATH}) | Out-Null;

# install latest SQL CU
RUN C:\\downloads\\SQLServer2019-CU-x64.exe /X:C:/downloads/CU;
RUN C:\\downloads\\CU\\SETUP.EXE /action=patch /quiet /IAcceptSQLServerLicenseTerms

# install Sitecore stock dacpac's
COPY --from=scr.sitecore.com/sxp/sitecore-xm1-mssql-init:10.2.0-ltsc2019 C:\resources C:\mssql-init\resources\

# install scripts
COPY *.ps1 C:/

# cleanup
RUN Remove-Item -Path 'C:\\downloads' -Force -Recurse

###

ARG BUILD_CONFIGURATION='Release'

ENV SITECORE_LICENSE_LOCATION='C:\license\license.xml' `
    Sitecore_ConnectionStrings_Core='Data Source=(LocalDB)\.\SC;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Security='Data Source=(LocalDB)\.\SC;Integrated Security=true;Initial Catalog=Sitecore.Core;' `
    Sitecore_ConnectionStrings_Master='Data Source=(LocalDB)\.\SC;Integrated Security=true;Initial Catalog=Sitecore.Master;' `
    Sitecore_ConnectionStrings_Web='Data Source=(LocalDB)\.\SC;Integrated Security=true;Initial Catalog=Sitecore.Web;' `
    Sitecore_ConnectionStrings_ExperienceForms='Data Source=(LocalDB)\.\SC;Integrated Security=true;Initial Catalog=Sitecore.ExperienceForms;' `
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
