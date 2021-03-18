
$ModuleManifestName = 'ScriptLogger.psd1'
$ModuleManifestPath = '{0}\..\ScriptLogger\{1}' -f $PSScriptRoot, $ModuleManifestName

Import-Module -FullyQualifiedName $ModuleManifestPath -Force


function Test-Log ([string]$Type) {
    switch -Regex ($Type) {
        'File' {
            Set-Item -Path 'env:\LOGFILE' -Value 'C:\Temp\ScriptLogger.log'
            Write-Log -Message 'Rotating log file' -LogFile $env:LOGFILE -ForceRotate
        }

        'Name' {
            Set-Item -Path 'env:\LOGNAME' -Value 'ScriptLogger'
            Set-Item -Path 'env:\LOGSOURCE' -Value 'Test-Log'
        }
    }

    foreach ($type in ('Error', 'Warning', 'Info', 'Verbose', 'Debug')) {
       Set-Item -Path 'env:\LOGLEVEL' -Value $type -PassThru | Logger -Debug

        foreach ($level in (-1, 0, 1)) {
            Set-Item -Path 'env:\VERBOSITY' -Value $level -PassThru | Logger -Debug

            Write-Log -Level Error   -Message 'This is an error'
            Write-Log -Level Warning -Message 'This is a warning'
            Write-Log -Level Info    -Message 'This is an info message'

            Write-Log -Level Verbose0 -Message 'This is verbose message'
            Write-Log -Level Verbose1 -Message 'This is very verbose'
            Write-Log -Level Verbose2 -Message 'This is very very verbose'

            # Write-Log -Level Debug -Value 0 -Message 'This is a debug message'
            # Write-Log -Level Debug -Value 1 -Message 'This is a trace message'
        }
    }

    foreach ($variable in ('LOGFILE', 'LOGNAME', 'LOGSOURCE', 'LOGLEVEL', 'VERBOSITY')) {
        Remove-Item -Path (Join-Path -Path 'env:' -ChildPath $variable) -ErrorAction Ignore
    }
}

function Invoke-Project {
    [CmdletBinding()]
    param (
        [Parameter(DontShow = $true)]
        [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug')]
        [string]$LogLevel = 'Info',

        [Parameter(DontShow = $true)]
        [ValidateRange(-1, 65535)]
        [nullable[int]]$Verbosity = 0
    )

    if ($PSBoundParameters.ContainsKey('Verbose')) { $LogLevel = 'Verbose' }
    if ($PSBoundParameters.ContainsKey('Debug'))   { $LogLevel = 'Debug'   }

    Write-Log -Level Error   -Message 'This is an error'
    Write-Log -Level Warning -Message 'This is a warning'
    Write-Log -Level Info    -Message 'This is an info message'

    Write-Log -Level Verbose0 -Message 'This is verbose message'
    Write-Log -Level Verbose1 -Message 'This is very verbose'
    Write-Log -Level Verbose2 -Message 'This is very very verbose'

    Write-Log -Level Debug -Value 0 -Message 'This is a debug message'
    Write-Log -Level Debug -Value 1 -Message 'This is a trace message'
}

function Write-Streams {
    Write-Error   'This is an error'
    Write-Warning 'This is a warning'
    Write-Output  'This is an info message'

    Write-Verbose 'This is a verbose message' -Verbose
    Write-Debug   'This is a debug message'   -Debug
}


Test-Log

# Test-Log -Type 'File'
# Test-Log -Type 'Name'


# Invoke-Project -LogLevel Verbose
Invoke-Project -Verbosity 1 -Debug

# Write-Streams *>&1 | Write-Log -Verbose
Write-Streams *>&1 | Write-Log -LogLevel Debug
