#Get-BlueJeansAPIMeeting.ps1

function Get-BlueJeansAPIMeeting {
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [hashtable]$AuthObject,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$UserID = $AuthObject.UserID,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$false, position=3)]
        [string]$MeetingInternalID
    )

    $uri = "https://api.bluejeans.com/v1/user/{0}/scheduled_meeting" -f $UserId
    if ($MeetingInternalID) {
        $uri = $uri + "/$MeetingInternalID"
    }

    write-Host $uri

    $headers = @{
        accept="application/json"
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

    $r = Invoke-BlueJeansAPIRequest -Uri $uri -Method Get -AuthObject $AuthObject -Headers $headers

    $r.Meetings = $r.Body

    $r

}