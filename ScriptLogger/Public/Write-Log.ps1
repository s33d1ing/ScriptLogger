function Write-Log {

    <#
        .SYNOPSIS
            Writes an event message to the console and to a log file or event log.

        .DESCRIPTION
            Prints a formatted message to the console, and/or creates a Configuration
            Manager (CMTrace) compatible log file or writes to the Windows EventLog.


        .PARAMETER Level
            Specifies the level of the event message.

                   Error  Due to a more serious problem, the software has not been able to perform some function.
                 Warning  An indication that something unexpected happened, or indicative of a problem in the future.
                    Info  Confirmation that things are working as expected.
                 Verbose  Additional information about command processing.
                   Debug  Detailed information, typically of interest only when diagnosing problems.

                Progress  Used for messages that communicate progress in longer running commands and scripts.

            A number can be appended to the end of the level (e.g. Verbose3) to automatically set the value.
            If Progress is specified, additional parameters are enabled and Write-Log will mimic Write-Progress.

        .PARAMETER Value
            Specifies the verbosity of the event message.


        .PARAMETER InputObject
            Specifies the event message or the first line of text in the status bar.


        .PARAMETER Status
            Specifies the second line of text in the heading above the status bar.

        .PARAMETER Id
            Specifies an ID that distinguishes each progress bar from the others.

        .PARAMETER PercentComplete
            Specifies the percentage of the activity that is completed.

        .PARAMETER SecondsRemaining
            Specifies the projected number of seconds remaining until the activity is completed.

        .PARAMETER CurrentOperation
            Specifies the line of text below the progress bar.

        .PARAMETER ParentId
            Specifies the parent activity of the current activity.

        .PARAMETER Completed
            Indicates whether the progress bar is visible.

        .PARAMETER SourceId
            Specifies the source of the record.


        .PARAMETER LogFile
            Specifies the path of the log file to which the event is written.

        .PARAMETER LogFormat
            Specifies whether to create a CMTrace compatable or human readable log file.


        .PARAMETER LogName
            Specifies the name of the event log to which the event is written.

        .PARAMETER LogSource
            Specifies the source, which is typically the name of the application, that is writing the event to the log.

        .PARAMETER EventId
            Specifies the event identifier.

        .PARAMETER EventCategory
            Specifies a task category for the event.


        .PARAMETER TeeConsole
            Specifies whether to output to the console as well as the log file or event log.

        .PARAMETER RewriteLines
            If the message is the same as the previous message, overwrite the previous message in the console.


        .PARAMETER ThreadSafe
            Utilize a mutex to block access to the log file while another thread is writing to it.

        .PARAMETER MutexTimeout
            The number of milliseconds to wait, or infinite (-1) to wait indefinitely.


        .PARAMETER EnableRotation
            Enables log rotation when a log file reaches a certain size or age.

        .PARAMETER MaxLogFiles
            How many time log files are rotated, or infinite (-1) to keep indefinitely.

        .PARAMETER MaxLogSize
            The size (in bytes) a log file must be before being rotated.

        .PARAMETER MaxLogAge
            The age (in days) a log file must be before being rotated.

        .PARAMETER ForceRotate
            Force rotation even if the log file does not meet the criteria.


        .PARAMETER LogLevel
            Specifies the threshold of messages to be logged.

                By default both the Level and the LogLevel are set to Info. When set to Info, all Info messages and any
                higher levels (i.e. Warning and Error) will be logged. Setting to Verbose or Debug will increase logging.

                Setting to Trace will log all messages regardless of LogLevel or Verbosity.

            Intended to be set by the calling module or project through an environment or private variable.

        .PARAMETER Verbosity
            Increases the verbosity of messages being logged.

                By default both the Value and the Verbosity are set to 0. If the message's value has been increased,
                the message will only be written to the console if the Verbosity is greater than or equal to it.

                All messages of the specified LogLevel will be written to the log file or event log regardless of the Value.

            Intended to be set by the calling module or project through an environment or private variable.


        .EXAMPLE
            Write-Log [[-Level] <string>] [-Value <int>] [-InputObject] <Object>

            [-Status <string>] [-Id <int>] [-PercentComplete <int>] [-SecondsRemaining <int>]
            [-CurrentOperation <string>] [-ParentId <int>] [-Completed] [-SourceId <int>]

            -LogFile <string> [-LogFormat <string>] [-EnableRotation <bool>]
            [-MaxLogFiles <int>] [-MaxLogSize <int>] [-MaxLogAge <int>] [-ForceRotate]

            -LogName <string> [-LogSource <string>] [-EventId <int>] [-EventCategory <int>]

            [-TeeConsole <bool>] [-RewriteLines <bool>] [-ThreadSafe <bool>] [-MutexTimeout <int>]
            [-LogLevel <string>] [-Verbosity <int>] [<CommonParameters>]
    #>

    [Alias('Logger')]
    [CmdletBinding(DefaultParameterSetName = 'Console')]

    param (
        [Parameter(Position = 0)]
        [ValidatePattern('^(Error|Warning|Info|Verbose|Debug|Progress)(\d+)?$')]
        # [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug', 'Progress')]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable')]
        [string]$Level = 'Info',

        [Parameter(DontShow = $true)]
        [ValidateRange(0, 2147483647)]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable')]
        [nullable[int]]$Value = 0,


        [Alias('Activity', 'Message')]
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [object]$InputObject,


        [Parameter(DontShow = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [string]$Status,

        [Parameter(DontShow = $true)]
        [ValidateRange(0, 2147483647)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [int]$Id,

        [Parameter(DontShow = $true)]
        [ValidateRange(-1, 100)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [int]$PercentComplete,

        [Parameter(DontShow = $true)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [int]$SecondsRemaining,

        [Parameter(DontShow = $true)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [string]$CurrentOperation,

        [Parameter(DontShow = $true)]
        [ValidateRange(-1, 2147483647)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [int]$ParentId,

        [Parameter(DontShow = $true)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [switch]$Completed,

        [Parameter(DontShow = $true)]
        [ValidateScript({$Level -eq 'Progress'})]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Variable', Progress = $true)]
        [int]$SourceId,


        [Alias('File', 'Path')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFile')]
        [ValidateScript({Test-Path -Path $PSItem -IsValid})]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [string]$LogFile,

        [Alias('Format')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateSet('CMTrace', 'PlainText')]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [string]$LogFormat = 'CMTrace',


        [Alias('Name')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EventLog')]
        [ScriptLogger(ParameterSets = 'EventLog', ParameterType = 'Constant')]
        [string]$LogName,

        [Alias('Source')]
        [Parameter(ParameterSetName = 'EventLog')]
        [ScriptLogger(ParameterSets = 'EventLog', ParameterType = 'Constant')]
        [string]$LogSource,

        # [Alias('Id')]
        [Parameter(ParameterSetName = 'EventLog')]
        [ValidateRange(0, 65535)]
        [ScriptLogger(ParameterSets = 'EventLog', ParameterType = 'Constant')]
        [int]$EventId,

        # [Alias('Category')]
        [Parameter(ParameterSetName = 'EventLog')]
        [ValidateRange(0, 65535)]
        [ScriptLogger(ParameterSets = 'EventLog', ParameterType = 'Constant')]
        [int]$EventCategory,


        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Constant')]
        [bool]$TeeConsole = $true,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Constant')]
        [bool]$RewriteLines = $true,


        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ScriptLogger(ParameterSets = ('EventLog', 'LogFile'), ParameterType = 'Constant')]
        [bool]$ThreadSafe = $true,

        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateRange(-1, 65535)]
        [ScriptLogger(ParameterSets = ('EventLog', 'LogFile'), ParameterType = 'Constant')]
        [int]$MutexTimeout = 1000,


        [Parameter(ParameterSetName = 'LogFile')]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [bool]$EnableRotation = $true,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -ge -1})]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [int]$MaxLogFiles = 5,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -gt 0})]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [int]$MaxLogSize = 10MB,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -gt 0})]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Constant')]
        [int]$MaxLogAge = 7,

        [Parameter(ParameterSetName = 'LogFile')]
        [ScriptLogger(ParameterSets = 'LogFile', ParameterType = 'Variable')]
        [switch]$ForceRotate,


        [Parameter(DontShow = $true, ParameterSetName = 'Console')]
        [Parameter(DontShow = $true, ParameterSetName = 'EventLog')]
        [Parameter(DontShow = $true, ParameterSetName = 'LogFile')]
        [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug',  'Trace')]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Constant')]
        [string]$LogLevel = 'Info',

        [Parameter(DontShow = $true, ParameterSetName = 'Console')]
        [Parameter(DontShow = $true, ParameterSetName = 'EventLog')]
        [Parameter(DontShow = $true, ParameterSetName = 'LogFile')]
        [ValidateRange(-1, 2147483647)]
        [ScriptLogger(ParameterSets = ('Console', 'EventLog', 'LogFile'), ParameterType = 'Constant')]
        [nullable[int]]$Verbosity = 0
    )

    begin {
        if ($ThreadSafe) { $mutex = [System.Threading.Mutex]::new($false, 'Global\Logger') }


        foreach ($parameter in $PSCmdlet.MyInvocation.MyCommand.Parameters.Values) {
            if ($parameter.Attributes | Where-Object { $PSItem.TypeId.Name -eq 'ScriptLoggerAttribute' } |
                Where-Object { ($PSItem.ParameterType -eq 'Constant') -or $PSItem.Constant }) {

                if (-not $PSBoundParameters.ContainsKey($parameter.Name)) {

                    if (($variable = [System.Environment]::GetEnvironmentVariable($parameter.Name)) -or
                        ($variable = Get-Variable -Name $parameter.Name -ValueOnly -ErrorAction Ignore)) {

                        Set-Variable -Name 'bool', 'int' -Value $null

                        if ([bool]::TryParse($variable, [ref]$bool)) { $variable = $bool }
                        if ([int]::TryParse($variable, [ref]$int)) { $variable = $int }

                        # $PSBoundParameters[$parameter.Name] = $variable
                        Set-Variable -Name $parameter.Name -Value $variable
                    }

                }
            }
        }


        if ($Level -match '^(?<Level>Error|Warning|Info|Verbose|Debug|Progress)(?<Value>\d+)?$') {
            if (-not [string]::IsNullOrEmpty($Matches.Level)) { $Level = $Matches.Level }
            if (-not [string]::IsNullOrEmpty($Matches.Value)) { $Value = $Matches.Value }
        }

        if ($PSBoundParameters.ContainsKey('Verbose')) { Set-Variable -Name 'Level', 'LogLevel' -Value 'Verbose' }
        if ($PSBoundParameters.ContainsKey('Debug')) { Set-Variable -Name 'Level', 'LogLevel' -Value 'Debug' }


        if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
            $LogFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogFile)

            New-Item -Path (Split-Path -Path $LogFile -Parent) -ItemType Directory -Force | Out-Null


            $caller = Get-PSCallStack | Where-Object { $PSItem.Command } | Select-Object -Skip 1 -First 1

            $username = [System.Environment]::UserDomainName + '\' + [System.Environment]::UserName
            $thread = [System.Threading.Thread]::CurrentThread.ManagedThreadId


            $fileinfo = @{
                FilePath = $LogFile
                Encoding = 'utf8'

                  Append = $true
                   Force = $true

                 Confirm = $false
                  WhatIf = $false
            }


            if ($EnableRotation -and (Test-Path -Path $LogFile)) {
                if ((-not $ThreadSafe) -or ($mutex.WaitOne($MutexTimeout))) {

                    $rotate = @{
                            LogFile = $LogFile

                        MaxLogFiles = $MaxLogFiles
                         MaxLogSize = $MaxLogSize
                          MaxLogAge = $MaxLogAge

                        ForceRotate = $ForceRotate
                    }

                    Backup-Log @rotate


                    if ($ThreadSafe) { $mutex.ReleaseMutex() }
                }
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($LogName)) {
            if ([string]::IsNullOrWhiteSpace($LogSource)) { $LogSource = $LogName }

            if (-not $PSBoundParameters.ContainsKey('EventId')) { $EventId = [math]::Abs($LogTypes.Item($Level)) }
            if (-not $PSBoundParameters.ContainsKey('Category')) { $EventCategory = [int]::new() }


            $eventinfo = @{
                  LogName = $LogName
                   Source = $LogSource

                EntryType = $Level -replace 'Info|Verbose|Debug', 'Information'

                  EventId = $EventId
                 Category = $EventCategory
            }


            if (($PSEdition -ne 'Core') -and (Confirm-Privileges)) {
                New-EventLog -LogName $LogName -Source $LogSource -ErrorAction Ignore
            }
        }


        [console]::CursorVisible = $false
    }

    process {
        $logtext = $InputObject | ConvertTo-String
        $timestamp = [System.DateTime]::Now


        if (-not ($PSBoundParameters.Keys | Where-Object { $PSItem -in 'Level', 'Verbose', 'Debug' })) {
            switch (Select-Object -InputObject $InputObject.GetType() -ExpandProperty Name) {

                  'ErrorRecord' { Set-Variable -Name 'Level' -Value 'Error'   }
                'WarningRecord' { Set-Variable -Name 'Level' -Value 'Warning' }

                'VerboseRecord' { Set-Variable -Name 'Level' -Value 'Verbose' }
                  'DebugRecord' { Set-Variable -Name 'Level' -Value 'Debug'   }


                'InformationRecord' {
                    if ($InputObject.MessageData.GetType() -match 'ProgressRecord') {
                        Set-Variable -Name 'InputObject' -Value $InputObject.MessageData
                    }
                }

                { $PSItem, $InputObject.GetType() -match 'ProgressRecord' } {
                    Set-Variable -Name 'Level' -Value 'Progress'


                    # Set-Variable -Name 'Activity'         -Value $InputObject.Activity
                    Set-Variable -Name 'Status'           -Value $InputObject.StatusDescription
                    Set-Variable -Name 'Id'               -Value $InputObject.ActivityId
                    Set-Variable -Name 'PercentComplete'  -Value $InputObject.PercentComplete
                    Set-Variable -Name 'CurrentOperation' -Value $InputObject.CurrentOperation
                    Set-Variable -Name 'SecondsRemaining' -Value $InputObject.SecondsRemaining
                    Set-Variable -Name 'ParentId'         -Value $InputObject.ParentActivityId

                    switch ($InputObject.RecordType) {
                        'Completed'  { Set-Variable -Name 'Completed' -Value $true  }
                        'Processing' { Set-Variable -Name 'Completed' -Value $false }
                    }


                    # Set-Variable -Name 'InputObject' -Value $InputObject.Activity
                    $PSBoundParameters['InputObject'] = $InputObject.Activity
                }


                default { Set-Variable -Name 'Level' -Value 'Info' }
            }
        }

        if ($Level -eq 'Progress') {
            $parameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values | Where-Object {
                $PSItem.Attributes | Where-Object { ($PSItem.TypeId.Name -eq 'ScriptLoggerAttribute') -and $PSItem.Progress }
            }

            $progress = Get-ParameterValues -Cmdlet $PSCmdlet -Include $parameters.Name
            $logtext = Format-Progress @progress -Width ($Host.UI.RawUI.BufferSize.Width - 28)
        }


        if ((-not $ThreadSafe) -or ($mutex.WaitOne($MutexTimeout))) {
            if (($LogLevel -eq 'Trace') -or ($LogTypes.Item($Level) -ge $LogTypes.Item($LogLevel))) {

                if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
                    switch ($LogFormat) {

                        'CMTrace' {
                            $string = [System.Text.StringBuilder]::new()

                            [void]$string.AppendFormat('<![LOG[{0}]LOG]!><',            $logtext                )
                            [void]$string.AppendFormat('time="{0:HH:mm:ss.fff}+000" ',  $timestamp              )
                            [void]$string.AppendFormat('date="{0:MM-dd-yyyy}" ',        $timestamp              )
                            [void]$string.AppendFormat('component="{0}" ',              $caller.Command         )
                            [void]$string.AppendFormat('context="{0}" ',                $username               )
                            [void]$string.AppendFormat('type="{0}" ',                   $LogTypes.Item($Level)  )
                            [void]$string.AppendFormat('thread="{0}" ',                 $thread                 )
                            [void]$string.AppendFormat('file="{0}">',                   $caller.Location        )

                            Out-File -InputObject $string.ToString() @fileinfo
                        }

                        'PlainText' {
                            foreach ($line in (Split-Line -Message $logtext)) {
                                Out-File -InputObject ('[{0:HH:mm:ss.fff}] ' -f $timestamp) -NoNewLine  @fileinfo
                                Out-File -InputObject ('{0,-10}' -f $Level.ToUpper())       -NoNewLine  @fileinfo

                                Out-File -InputObject $line.TrimEnd() @fileinfo
                            }
                        }
                    }
                }

                if (-not [string]::IsNullOrWhiteSpace($LogName)) {
                    if (($PSEdition -ne 'Core') -and (Confirm-Privileges)) {
                        Write-EventLog -Message ($logtext -replace '(?m)\s*$') @eventinfo
                    }
                }


                if ($TeeConsole -and (($LogLevel -eq 'Trace') -or ($Value -le $Verbosity) -or ($PSBoundParameters.Keys -match 'Debug|Verbose'))) {
                    if ($RewriteLines -and ($Level -eq 'Progress') -and ($script:WriteProgress.Count -gt 0)) { Move-Cursor -Y -8 }

                    foreach ($line in (Split-Line -Message $logtext -Width ($Host.UI.RawUI.WindowSize.Width - 26))) {
                        if ($RewriteLines -and ($Level -ne 'Progress') -and ($script:LastMessage -eq $line)) { Move-Cursor -Y -1 }

                        Write-Host -Object ('[{0:HH:mm:ss.fff}] ' -f $timestamp)    -NoNewLine  -ForegroundColor $LogColors.Timestamp
                        Write-Host -Object ('{0,-10}'-f $Level.ToUpper())           -NoNewLine  -ForegroundColor $LogColors.Item($Level)

                        switch ($InputObject.MessageData.ForegroundColor) {
                            { $null -eq $PSItem } { Write-Host -Object $line -ForegroundColor $LogColors.Message }
                            { $null -ne $PSItem } { Write-Host -Object $line -ForegroundColor $PSItem }
                        }

                        if ($RewriteLines -and ($Level -ne 'Progress')) {
                            $script:LastMessage = $line
                            $script:WriteProgress.Clear()
                        }
                    }

                    if ($RewriteLines -and ($Level -eq 'Progress')) {
                        $script:LastMessage = [string]::Empty
                        $script:WriteProgress.Add($progress)

                        if ($Completed -and ([string]::IsNullOrEmpty($progress.ParentId) -or
                            ($progress.ParentId -notin $script:WriteProgress.Id))) {

                            $script:WriteProgress.Clear()
                        }
                    }
                }
            }

            if ($ThreadSafe) { $mutex.ReleaseMutex() }
        }
    }

    end {
        if ($ThreadSafe) { $mutex.Dispose() }

        [console]::CursorVisible = $true
    }
}
