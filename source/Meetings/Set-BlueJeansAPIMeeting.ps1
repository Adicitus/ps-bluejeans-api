#New-BlueJeansAPIMeeting.ps1

function set-BlueJeansAPIMeeting {
    param(
        [Parameter(Mandatory=$true, position=1)]
        [hashtable]$AuthObject,
        [Parameter(Mandatory=$false, position=2)]
        [string]$UserID=$AuthObject.UserID,
        [Parameter(Mandatory=$true, position=3)]
        [string]$MeetingInternalID,
        [Parameter(Mandatory=$false, ParameterSetName="Hashtable")]
        [hashtable]$Meeting,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [string]$Title,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [datetime]$StartTime,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
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
        [Parameter(Mandatory=$false)]
        [hashtable]$ExtraHeaders
    )

    $uri = "https://api.bluejeans.com/v1/user/{0}/scheduled_meeting/{1}" -f $UserId, $MeetingInternalID

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
                $ts.TotalSeconds
            }

            $b = @{}

            $mapping = @{
                Title = { $b.title = $Title }
                StartTime       = { $b.start = & $toUnixMS $StartTime }
                EndTime         = { $b.end = & $toUnixMS $EndTime }
                EndpointType    = { $b.endPointType = $EndpointType }
                EndpointVersion = { $b.endPointVersion = $EndpointVersion }
                TimeZone        = { $b.timezone = $TimeZone }
                Description     = { $b.description = $Description }
                IsLargeMeeting  = { $b.isLargeMeeting = $true }
            }

            $PSBoundParameters.GetEnumerator() | % {
                if ($mapping.ContainsKey($_.Key)) {
                    & $mapping[$_.Key]
                }
            }

            $b
        }
    }

    $r = Invoke-BlueJeansAPIRequest -Uri $uri -Method Put -AuthObject $AuthObject -Headers $headers -Body $body

    $r.Meeting = $r.Body

    $r

}