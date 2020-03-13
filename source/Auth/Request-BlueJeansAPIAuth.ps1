#Request-BlueJeansAPIAuth.ps1

function request-BlueJeansAPIAuth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Password", Position=1)]
        [pscredential]$Credential
    )

    $uri = "https://api.bluejeans.com/oauth2/token?{0}" -f $PSCmdlet.ParameterSetName

    $headers = @{
        "Content-Type"="application/json"
    }

    write-Host $uri

    $body = @{
        grant_type="password"
        username=$Credential.UserName
        password=Unlock-SecureString $Credential.Password
    }
    $jsonbody = $body | ConvertTo-Json -Depth 10

    $jsonbody = ConvertTo-UnicodeEscapedString $jsonbody

    $r = Invoke-WebRequest -Method Post -Uri $uri -Body $jsonbody -Headers $headers -UseBasicParsing

    $j = $r.Content | ConvertFrom-Json

    
    @{
        Credential=$Credential
        UserID=$j.scope.user
        Expires = [datetime]::now.AddSeconds($j.expires_in)
        AccessToken = ConvertTo-SecureString $j.access_token -AsPlainText -Force
    }

}