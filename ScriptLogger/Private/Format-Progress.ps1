function Format-Progress {

    param (
        [Alias('InputObject')]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Activity,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,

        [Parameter(Position = 2)]
        [ValidateRange(0, 2147483647)]
        [int]$Id,

        [Parameter()]
        [ValidateRange(-1, 100)]
        [int]$PercentComplete,

        [Parameter()]
        [int]$SecondsRemaining,

        [Parameter()]
        [string]$CurrentOperation,

        [Parameter()]
        [ValidateRange(-1, 2147483647)]
        [int]$ParentId,

        [Parameter()]
        [switch]$Completed,

        [Parameter()]
        [int]$SourceId,


        [Parameter(DontShow = $true)]
        [int]$Width = $Host.UI.RawUI.BufferSize.Width - 1,

        [Parameter(DontShow = $true)]
        [int]$Indentation = 0
    )


    $string = [System.Text.StringBuilder]::new()
    $empty = [string]::Empty.PadRight($Width)

    [void]$string.AppendLine()
    [void]$string.Append(' ' * $Indentation)
    [void]$string.AppendLine($Activity.PadRight($Width - $Indentation))

    $Indentation = $Indentation + 4


    if ($PSBoundParameters.ContainsKey('Status')) {
        [void]$string.Append(' ' * $Indentation)
        [void]$string.AppendLine($Status.PadRight($Width - $Indentation))
    }
    else { [void]$string.AppendLine($empty) }


    if ($PSBoundParameters.ContainsKey('PercentComplete') -and ($PercentComplete -ne -1)) {
        if ($Completed.IsPresent) { $PercentComplete = 100 }

        $bar = (($Width - $Indentation) - 6) / 100

        $filled = 'o' * [math]::Floor($PercentComplete * $bar)
        $remaining = ' ' * (($bar * 100) - $filled.Length)

        $progress = [string]::Concat('[', $filled, $remaining, ']')

        [void]$string.Append(' ' * $Indentation)
        [void]$string.AppendLine($progress.PadRight($Width - $Indentation))
    }
    else { [void]$string.AppendLine($empty) }


    if ($PSBoundParameters.ContainsKey('SecondsRemaining') -and ($SecondsRemaining -ne -1)) {
        if ($Completed.IsPresent) { $SecondsRemaining = 0 }

        $timespan = [timespan]::FromSeconds($SecondsRemaining)

        [void]$string.Append(' ' * $Indentation)
        [void]$string.AppendFormat('{0:hh\:mm\:ss} remaining.', $timespan)
        [void]$string.AppendLine($empty.Substring(0, $empty.Length - 22))
    }
    else { [void]$string.AppendLine($empty) }


    [void]$string.AppendLine($empty)

    if ($PSBoundParameters.ContainsKey('CurrentOperation')) {
        [void]$string.Append(' ' * $Indentation)
        [void]$string.AppendLine($CurrentOperation.PadRight($Width - $Indentation))
    }
    else { [void]$string.AppendLine($empty) }


    $string.ToString()  # -replace '\r?\n(?!\r?\n)$'
}
