
function Update-BlueJeansAPIAuth {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$AuthObject
    )

    $r = request-BlueJeansAPIAuth $AuthObject.Credential

    $AuthObject.Expires = $r.Expires
    $AuthObject.AccessToken = $r.AccessToken
}