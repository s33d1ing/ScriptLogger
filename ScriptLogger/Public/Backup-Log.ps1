function Backup-Log {

    <#
        .PARAMETER LogFile
            Specifies the path of the log file to which the event is written.


        .PARAMETER MaxLogFiles
            How many time log files are rotated, or infinite (-1) to keep indefinitely.

        .PARAMETER MaxLogSize
            The size (in bytes) a log file must be before being rotated.

        .PARAMETER MaxLogAge
            The age (in days) a log file must be before being rotated.


        .PARAMETER ForceRotate
            Force rotation even if the log file does not meet the criteria.
    #>

    [Alias('LogRotate')]
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]

    param (
        [Alias('File', 'Path')]
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $PSItem -IsValid})]
        [string]$LogFile,


        [Parameter()]
        [ValidateScript({$PSItem -ge -1})]
        [int]$MaxLogFiles = 5,

        [Parameter()]
        [ValidateScript({$PSItem -gt 0})]
        [int]$MaxLogSize = 10MB,

        [Parameter()]
        [ValidateScript({$PSItem -gt 0})]
        [int]$MaxLogAge = 7,


        [Parameter()]
        [switch]$ForceRotate
    )

    $LogFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogFile)


    if ($item = Get-Item -Path $LogFile -ErrorAction Ignore) {
        $age = New-TimeSpan -Start $item.LastWriteTime | Select-Object -ExpandProperty Days

        if (($item.Length -gt $MaxLogSize) -or ($age -gt $MaxLogAge) -or $ForceRotate) {
            $name = [string]::Concat($item.BaseName, '(_\d+)?', $item.Extension)

            $files = Get-ChildItem -Path $item.Directory -File |
                Where-Object -Property Name -Match $name |
                Sort-Object -Property LastWriteTime -Descending


            for ($count = $files.Count; $count -gt 0; $count--) {
                $path = $files[$count - 1] | Select-Object -ExpandProperty FullName

                if (($MaxLogFiles -eq -1) -or ($count -le $MaxLogFiles)) {
                    $child = [string]::Concat($item.BaseName, '_', $count, $item.Extension)
                    $destination = Join-Path -Path $item.Directory -ChildPath $child

                    Move-Item -Path $path -Destination $destination -Force
                }
                else { Remove-Item -Path $path -Force }
            }
        }
    }
}
