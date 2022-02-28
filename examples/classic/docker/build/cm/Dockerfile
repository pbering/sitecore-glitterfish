# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE

FROM ${SOLUTION_IMAGE} AS solution

# ---
FROM ${PARENT_IMAGE}
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG BUILD_CONFIGURATION='Release'

COPY --from=solution /artifacts/platform/ ./
RUN & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath '.\Web.Common.config.xdt'; `
    & 'C:\tools\scripts\Invoke-XdtTransform.ps1' -Path '.\Web.config' -XdtPath ('.\Web.{0}.config.xdt' -f $env:BUILD_CONFIGURATION); `
    Remove-Item -Path '.\\Web.*.xdt' -Force;
