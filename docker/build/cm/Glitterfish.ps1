$template = @"

                    =+-.
                -*@@@@@%=
            .=%@@@@@@@@@@=.
            =@@@@@@@@@@@@@@@@@@%#+=:
    =#+-      -@@@@@@@@@@@@@@@@@@@@@@@#+:
    #@@@*. .+%@@@@@@@@@@@@@@@@@@%+-=*@@@%+.
    .@@@@@#@@@@@@@@@@@@@@@@@@@@* +%#.:@@@@@
    %@@@@@@@@@@@@@@@@@@@@@@@@@* *%#.:@@@@+
    %@@@@@@@@@@@@@@@@@@@@@@@@@@#=-=*@@@@#
    .@@@@%*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
    #@@@+   -#@@@@@@@@@@@@@@@@@@@@@@@@%-
    =*=:       =@@@@@@@@@@@@@@@@@@@@%+:
            .@@@@@@%**#%%%%%#*+=-.
            +*+=-:

"@

Write-Host "### Starting..."
Write-Host $template

. (Join-Path $PSScriptRoot ".\Boot.ps1")
. (Join-Path $PSScriptRoot ".\Development.ps1")