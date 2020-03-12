#Restore-BlueJeansAPIAuth.ps1

function Restore-BlueJeansAPIAuth {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $ss = Get-Content $Path | ConvertTo-SecureString
    $o = Unlock-SecureString $ss | ConvertFrom-Json
    $h = @{}
    $o | Get-Member -MemberType NoteProperty | % { $n = $_.Name; $h[$n] = $o.$n }

    $h
}