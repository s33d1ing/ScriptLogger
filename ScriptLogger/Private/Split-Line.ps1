function Split-Line {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string[]]$Message,

        [Parameter()]
        [ValidateScript({($PSItem -eq -1) -or ($PSItem -gt 3)})]
        [int]$Width = -1,

        [Parameter()]
        [bool]$Truncate = $true
    )

    process {
        foreach ($line in ($Message -replace '\r' -split '\n')) {
            if (($Width -ne -1) -and ($Width -gt 3)) {
                $part = [string]::Empty

                foreach ($word in ($line -split '\s')) {
                    if (($word.Length -gt $Width) -and $Truncate) {
                        $trim = $word.Substring(0, ($Width - 3))
                        $word = [string]::Concat($trim, '...')
                    }

                    if (($part.Length + $word.Length) -ge $Width) {
                        if ($part.Length -gt 0) { $part.TrimEnd() }

                        $part = [string]::Concat($word, ' ')
                    }
                    else {
                        $part = [string]::Concat($part, $word, ' ')
                    }
                }

                $part.TrimEnd()
            }
            else { $line }
        }
    }
}
