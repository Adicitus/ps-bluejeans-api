#Restore-BlueJeansAPIAuth.ps1

function Restore-BlueJeansAPIAuth {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $ss = Get-Content $Path | ConvertTo-SecureString
    $o = Unlock-SecureString $ss | ConvertFrom-Json

    $auth = @{}

    $auth.Expires = $o.Expires
    $auth.UserID  = $o.UserID
    $auth.Credential = New-PScredential -Username $o.Username -SecurePassword ($o.Password | ConvertTo-SecureString)
    $auth.AccessToken = $o.AccessToken | ConvertTo-SecureString
    
    $auth
}