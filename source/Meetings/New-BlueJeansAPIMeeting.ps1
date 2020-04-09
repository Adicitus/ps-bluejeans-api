#New-BlueJeansAPIMeeting.ps1

function New-BlueJeansAPIMeeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, position=1)]
        [hashtable]$AuthObject,
        [Parameter(Mandatory=$false, position=2)]
        [string]$UserID=$AuthObject.UserID,
        [Parameter(Mandatory=$true, ParameterSetName="Hashtable")]
        [hashtable]$Meeting,
        [Parameter(Mandatory=$true, ParameterSetName="Params")]
        [string]$Title,
        [Parameter(Mandatory=$true, ParameterSetName="Params")]
        [datetime]$StartTime,
        [Parameter(Mandatory=$true, ParameterSetName="Params")]
        [datetime]$EndTime,
        [ValidateSet("WEB_APP")]
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [string]$EndpointType="WEB_APP",
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [string]$EndpointVersion="2.10",
        [Parameter(Mandatory=$false, ParameterSetName="Params", HelpMessage="Time zone name as specified at 'https://en.wikipedia.org/wiki/List_of_tz_database_time_zones'. Default: 'Europe/Stockholm'")]
        [string]$TimeZone="Europe/Stockholm",
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [string]$Description,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [switch]$IsLargeMeeting,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [bool]$IsTimeless,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [bool]$IsEndless,
        [Parameter(Mandatory=$false)]
        [hashtable]$ExtraHeaders
    )

    $uri = "https://api.bluejeans.com/v1/user/{0}/scheduled_meeting" -f $UserId

    $headers = @{
        "Content-Type"="application/json"
    }

    if ($ExtraHeaders) {
        foreach ($header in $ExtraHeaders.Keys) {
            if ($headers.ContainsKey($header)) {
                $headers.$header = $headers.$header, $ExtraHeaders.$header -join ","
            } else {
                $headers.$Header = $ExtraHeaders.$header
            }
        }
    }

    $body = switch($PSCmdlet.ParameterSetName) {
        "Hashtable" {
            $Meeting
        }

        "Params" {
            $toUnixMS = {
                param([datetime]$d)

                $ts = $d - [datetime]::new(1970, 1, 1)
                $ts.TotalMilliSeconds
            }

            $b = @{
                endPointType = $EndpointType
                endPointVersion = $EndpointVersion
                timezone = $TimeZone
            }

            $mapping = @{
                Title = { $b.title = $Title }
                StartTime       = { $b.start = & $toUnixMS $StartTime }
                EndTime         = { $b.end = & $toUnixMS $EndTime }
                EndpointType    = { $b.endPointType = $EndpointType }
                EndpointVersion = { $b.endPointVersion = $EndpointVersion }
                TimeZone        = { $b.timezone = $TimeZone }
                Description     = { $b.description = $Description }
                IsLargeMeeting  = { $b.isLargeMeeting = $true }
                IsTimeless      = { $b.timelessMeeting = $IsTimeless }
                IsEndless       = { $b.endlessMeeting  = $IsEndless }
            }

            $PSBoundParameters.GetEnumerator() | % {
                if ($mapping.ContainsKey($_.Key)) {
                    & $mapping[$_.Key]
                }
            }

            $b
        }
    }

    $r = Invoke-BlueJeansAPIRequest -Uri $uri -Method Post -AuthObject $AuthObject -Headers $headers -Body $body

    $r.Meeting = $r.Body

    $r

}