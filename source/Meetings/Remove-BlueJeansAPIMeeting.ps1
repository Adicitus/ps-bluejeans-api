#Remove-BlueJeansAPIMeeting.ps1

function Remove-BlueJeansAPIMeeting {
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [hashtable]$AuthObject,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$UserID = $AuthObject.UserID,
        [Parameter(Mandatory=$true, position=3)]
        [string]$MeetingInternalID
    )

    $uri = "https://api.bluejeans.com/v1/user/{0}/scheduled_meeting/{1}" -f $UserId, $MeetingInternalID

    write-Host $uri

    $headers = $AuthObject.Headers.clone()

    if ($ExtraHeaders) {
        foreach ($header in $ExtraHeaders.Keys) {
            if ($headers.ContainsKey($header)) {
                $headers.$header = $headers.$header, $ExtraHeaders.$header -join ","
            } else {
                $headers.$Header = $ExtraHeaders.$header
            }
        }
    }

    Invoke-WebRequest -Uri $uri -Method Delete -Headers $headers -UseBasicParsing

}