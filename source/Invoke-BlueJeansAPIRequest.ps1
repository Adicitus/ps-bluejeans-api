#Invoke-BlueJeansAPIRequest.ps1

function Invoke-BlueJeansAPIRequest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Uri,
        [ValidateSet("Delete", "Get", "Post", "Put")]
        [Parameter(Mandatory=$true)]
        [string]$Method,
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$false)]
        [hashtable]$Headers=@{},
        [Parameter(Mandatory=$false)]
        [hashtable]$Body
    )

    if ($AuthObject.Expires -le [datetime]::Now) {
        Update-BlueJeansAPIAuth $AuthObject
    }

    $headers.Authorization = "bearer {0}" -f ( Unlock-SecureString $AuthObject.AccessToken )

    $reqArgs = @{
        Uri = $Uri
        Method = $Method
        Headers = $headers
    }

    if ($PSBoundParameters.ContainsKey("Body")) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10

        $reqArgs.Body = ConvertTo-UnicodeEscapedString $jsonBody
    }

    $r = try {
        Invoke-WebRequest @reqArgs -UseBasicParsing
    } catch {
        $_
    }

    switch ($r.GetType().Name) {
        ErrorRecord {}
        default {
            @{
                Statuscode=$r.statuscode
                Body=ConvertFrom-UnicodeEscapedString $r.Content | ConvertFrom-Json
            }
        }
    }
}