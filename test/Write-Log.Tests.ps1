
$ModuleManifestName = 'ScriptLogger.psd1'
$ModuleManifestPath = '{0}\..\ScriptLogger\{1}' -f $PSScriptRoot, $ModuleManifestName

Import-Module -FullyQualifiedName $ModuleManifestPath -Force


function Test-Log ([string]$Type, [switch]$Trace) {

    switch ($Type) {
        'File' {
            Set-Item -Path 'env:\LOGFILE' -Value 'C:\Temp\ScriptLogger.log'
            Write-Log -Message 'Rotating log file' -LogFile $env:LOGFILE -ForceRotate
        }

        'Name' {
            Set-Item -Path 'env:\LOGNAME' -Value 'ScriptLogger'
            Set-Item -Path 'env:\LOGSOURCE' -Value 'Test-Log'
        }
    }

    foreach ($level in ('Error', 'Warning', 'Info', 'Verbose', 'Debug')) {

        if ($Trace.IsPresent) { Set-Item -Path 'env:\LOGLEVEL' -Value 'Trace' }
        else { Set-Item -Path 'env:\LOGLEVEL' -Value $level -PassThru | Logger -Debug }

        foreach ($verbosity in (-1, 0, 1)) {
            Set-Item -Path 'env:\VERBOSITY' -Value $verbosity -PassThru | Logger -Debug

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
    Write-Host    'Writing all streams...' -ForegroundColor Green

    Write-Error   'This is an error'
    Write-Warning 'This is a warning'
    Write-Output  'This is an info message'

    Set-Variable -Name 'VerbosePreference', 'DebugPreference' -Value 'Continue'

    Write-Verbose 'This is a verbose message'  # -Verbose
    Write-Debug   'This is a debug message'    # -Debug
}

function Test-Rewrite {
    Write-Log -Message 'Starting'

    for ($i = 0; $i -le 10; $i++) {
        'Loading' + ('.' * ($Host.UI.RawUI.WindowSize.Width - 7)) | Logger -Verbose

        Start-Sleep -Milliseconds 750
    }

    Write-Log -Message 'Finished'
}

function Test-Progress {
    for ($count = 1; $count -le 60; $count++) {
        $percent = [math]::Floor($count / 60 * 100)
        $seconds = 15 * ($percent / 100)

        $parameters = @{
            Activity = 'Search in Progress'
            Status = '{0}% Complete' -f $percent
            PercentComplete = $percent
            SecondsRemaining = 15 - $seconds
            CurrentOperation = '{0:00} of 60' -f $count
        }

        if ($count -in 10..25) { $parameters.Remove('Status') }
        if ($count -in 20..35) { $parameters.Remove('PercentComplete') }
        if ($count -in 30..45) { $parameters.Remove('SecondsRemaining') }
        if ($count -in 40..55) { $parameters.Remove('CurrentOperation') }

        if ($count -eq 60) { $parameters.Completed = $true }

        Write-Log -Level Progress @parameters
        Start-Sleep -Milliseconds 250
    }
}

function Test-Pipeline {
    Write-Host 'Testing nested progress...' -ForegroundColor Green

    foreach ($i in 1..4) {
        # Write-Output 'Outer loop'

        $parameters = @{
            Activity = 'Step {0}' -f $i
            Percent = $i / 4 * 100
        }

        # if ($i -eq 4) { $parameters.Completed = $true }

        Write-Progress @parameters -Id 0
        Start-Sleep -Milliseconds 250

        foreach ($j in 1..6) {
            # Write-Output 'Middle loop'

            $parameters = @{
                Activity = 'Step {0} - Substep {1}' -f $i, $j
                Percent = $j / 6 * 100
            }

            if ($i -eq 6) { $parameters.Completed = $true }

            Write-Progress @parameters -Id 1 -ParentId 0
            Start-Sleep -Milliseconds 100

            foreach ($k in 1..8) {
                # Write-Output 'Inner loop'

                $parameters = @{
                    Activity = 'Step {0} - Substep {1} - Iteration {2}' -f $i, $j, $k
                    Percent = $k / 8 * 100
                }

                if ($i -eq 8) { $parameters.Completed = $true }

                Write-Progress @parameters -Id 2 -ParentId 1
                Start-Sleep -Milliseconds 25
            }
        }
    }
}


Test-Log  # -Trace

# Test-Log -Type 'File'
# Test-Log -Type 'Name'


# Invoke-Project -LogLevel Verbose
Invoke-Project -Verbosity 1 -Debug

# Write-Streams *>&1 | Write-Log -Verbose
Write-Streams *>&1 | Write-Log -LogLevel Debug


# Test-Rewrite
Test-Progress


Test-Pipeline *>&1 | Write-Log  # -Verbose
