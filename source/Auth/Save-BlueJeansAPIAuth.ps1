#Save-BlueJeansAPIAuth.ps1

function Save-BlueJeansAPIAuth {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [hashtable]$AuthObj
    )

    $authObjSerialized = @{}

    $authObjSerialized.AccessToken  = $AuthObj.AccessToken | ConvertFrom-SecureString
    $authObjSerialized.Username     = $AuthObj.Credential.Username
    $authObjSerialized.Password     = $AuthObj.Credential.Password | ConvertFrom-SecureString
    $authObjSerialized.UserID       = $AuthObj.UserID
    $authObjSerialized.Expires      = $AuthObj.Expires

    $authObjSerialized | ConvertTo-Json -Depth 10 | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString > $Path
}