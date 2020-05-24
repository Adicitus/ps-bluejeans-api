#Invoke-BlueJeansAPIRequest.ps1

function Invoke-BlueJeansAPIRequest {
    [CmdletBinding()]
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

    if ($reqArgs.ContainsKey("Body")) {
        Write-Debug "Invoking WebRequest with the following body:"
        Write-Debug $reqArgs.Body
    }

    $r = try {
        Invoke-WebRequest @reqArgs -UseBasicParsing
    } catch {
        $_
    }

    switch ($r.GetType().Name) {
        ErrorRecord {
            if ($r.Exception -is [System.Net.WebException]) {
                @{
                    StatusCode = $r.Exception.Response.StatusCode
                    Exception = $r.Exception
                    Response  = $r.Exception.Response
                }
            } else {
                throw $r
            }
        }
        default {
            $result = @{
                Statuscode=$r.statuscode
            }

            if ($r.Content) {
                $result.Body = ConvertFrom-UnicodeEscapedString $r.Content | ConvertFrom-Json
            }

            $result
        }
    }
}