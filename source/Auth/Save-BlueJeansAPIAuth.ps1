#Save-BlueJeansAPIAuth.ps1

function Save-BlueJeansAPIAuth {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [hashtable]$AuthObj
    )

    $AuthObj | ConvertTo-Json -Depth 10 | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString > $Path
}