function Write-Log {

    <#
        .SYNOPSIS
            Writes an event message to a log file or event log, and to the console.

        .DESCRIPTION
            Creates a Configuration Manager (CMTrace) compatible log file and/or
            writes an event to an event log, and formatted message for the console.


        .PARAMETER Level
            Specifies the level of the event message.

                  Error  Due to a more serious problem, the software has not been able to perform some function.
                Warning  An indication that something unexpected happened, or indicative of a problem in the future.
                   Info  Confirmation that things are working as expected.
                Verbose  Additional information about command processing.
                  Debug  Detailed information, typically of interest only when diagnosing problems.

            A number can be appended to the end of the level (e.g. Verbose3) to automatically set the value.

        .PARAMETER Value
            Specifies the verbosity of the event message.


        .PARAMETER Message
            Specifies the event message.


        .PARAMETER LogFile
            Specifies the path of the log file to which the event is written.

        .PARAMETER LogFormat
            Specifies whether to create a human readable or CMTrace compatable log file.


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

            Intended to be set by the calling module or project through an environment or private variable.

        .PARAMETER Verbosity
            Increases the verbosity of messages being logged.

                By default both the Value and the Verbosity are set to 0. If the message's value has been increased,
                the message will only be written to the console if the Verbosity is greater than or equal to it.

                All messages of the specified LogLevel will be written to the log file or event log regardless of the Value.

            Intended to be set by the calling module or project through an environment or private variable.
    #>

    [Alias('Logger')]
    [CmdletBinding(DefaultParameterSetName = 'Console')]

    param (
        [Parameter(Position = 0)]
        [ValidatePattern('^(Error|Warning|Info|Verbose|Debug)(\d+)?$')]
        # [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug')]
        [string]$Level = 'Info',

        [Parameter(DontShow = $true)]
        [ValidateRange(0, 65535)]
        [nullable[int]]$Value = 0,


        [Alias('Msg')]
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [object]$Message,


        [Alias('File', 'Path')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFile')]
        [ValidateScript({Test-Path -Path $PSItem -IsValid})]
        [string]$LogFile,

        [Alias('Format')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateSet('CMTrace', 'PlainText')]
        [string]$LogFormat = 'CMTrace',


        [Alias('Name')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EventLog')]
        [string]$LogName,

        [Alias('Source')]
        [Parameter(ParameterSetName = 'EventLog')]
        [string]$LogSource,

        [Alias('Id')]
        [Parameter(ParameterSetName = 'EventLog')]
        [ValidateRange(0, 65535)]
        [int]$EventId,

        [Alias('Category')]
        [Parameter(ParameterSetName = 'EventLog')]
        [ValidateRange(0, 65535)]
        [int]$EventCategory,


        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [bool]$TeeConsole = $true,


        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [bool]$ThreadSafe = $true,

        [Parameter(ParameterSetName = 'EventLog')]
        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateRange(-1, 65535)]
        [int]$MutexTimeout = 1000,


        [Parameter(ParameterSetName = 'LogFile')]
        [bool]$EnableRotation = $true,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -ge -1})]
        [int]$MaxLogFiles = 5,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -gt 0})]
        [int]$MaxLogSize = 1MB,

        [Parameter(ParameterSetName = 'LogFile')]
        [ValidateScript({$PSItem -gt 0})]
        [int]$MaxLogAge = 7,

        [Parameter(ParameterSetName = 'LogFile')]
        [switch]$ForceRotate,


        [Parameter(DontShow = $true, ParameterSetName = 'Console')]
        [Parameter(DontShow = $true, ParameterSetName = 'EventLog')]
        [Parameter(DontShow = $true, ParameterSetName = 'LogFile')]
        [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug')]
        [string]$LogLevel = 'Info',

        [Parameter(DontShow = $true, ParameterSetName = 'Console')]
        [Parameter(DontShow = $true, ParameterSetName = 'EventLog')]
        [Parameter(DontShow = $true, ParameterSetName = 'LogFile')]
        [ValidateRange(-1, 65535)]
        [nullable[int]]$Verbosity = 0
    )

    begin {
        if ($ThreadSafe) { $mutex = [System.Threading.Mutex]::new($false, 'Global\Logger') }


        foreach ($parameter in $PSCmdlet.MyInvocation.MyCommand.Parameters.Keys) {
            if ($parameter -notin ('Level', 'Value', 'Message', 'EventId', 'EventCategory')) {

                if (-not $PSBoundParameters.ContainsKey($parameter)) {
                    $path = Join-Path -Path 'env:' -ChildPath $parameter.ToUpper()

                    if (($item = Get-Item -Path $path -ErrorAction Ignore) -or
                        ($item = $PSCmdlet.SessionState.PSVariable.Get($parameter))) {

                        Set-Variable -Name 'bool', 'int' -Value $null

                        if ([bool]::TryParse($item.Value, [ref]$bool)) { $item.Value = $bool }
                        if ([int]::TryParse($item.Value, [ref]$int)) { $item.Value = $int }

                        # $PSBoundParameters[$parameter] = $item.Value
                        Set-Variable -Name $parameter -Value $item.Value
                    }
                }
            }
        }


        if ($Level -match '^(?<Level>Error|Warning|Info|Verbose|Debug)(?<Value>\d+)?$') {
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

            if (-not $PSBoundParameters.ContainsKey('EventId')) { $EventId = $LogTypes.Item($Level) -replace '-' }
            if (-not $PSBoundParameters.ContainsKey('Category')) { $EventCategory = [System.Int32]::new() }


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
    }

    process {
        $logtext = $Message | ConvertTo-String
        $timestamp = [System.DateTime]::Now


        #* If the level was not provided and the message is from a redirected stream, update the level
        if (-not ($PSBoundParameters.Keys | Where-Object { $PSItem -in 'Level', 'Verbose', 'Debug' })) {
            switch (Select-Object -InputObject $Message.GetType() -ExpandProperty Name) {

                  'ErrorRecord' { Set-Variable -Name 'Level' -Value 'Error'   }
                'WarningRecord' { Set-Variable -Name 'Level' -Value 'Warning' }

                'VerboseRecord' { Set-Variable -Name 'Level' -Value 'Verbose' }
                  'DebugRecord' { Set-Variable -Name 'Level' -Value 'Debug'   }

                        default { Set-Variable -Name 'Level' -Value 'Info'    }
            }
        }


        if ((-not $ThreadSafe) -or ($mutex.WaitOne($MutexTimeout))) {
            if ($LogTypes.Item($Level) -ge $LogTypes.Item($LogLevel)) {

                if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
                    switch ($LogFormat) {

                        'CMTrace' {
                            $string = [System.Text.StringBuilder]::new()

                            [void]$string.AppendFormat('<![LOG[{0}]LOG]!>',             $logtext                ).Append('<')
                            [void]$string.AppendFormat('time="{0:HH:mm:ss.fff}+000"',   $timestamp              ).Append(' ')
                            [void]$string.AppendFormat('date="{0:MM-dd-yyyy}"',         $timestamp              ).Append(' ')
                            [void]$string.AppendFormat('component="{0}"',               $caller.Command         ).Append(' ')
                            [void]$string.AppendFormat('context="{0}"',                 $username               ).Append(' ')
                            [void]$string.AppendFormat('type="{0}"',                    $LogTypes.Item($Level)  ).Append(' ')
                            [void]$string.AppendFormat('thread="{0}"',                  $thread                 ).Append(' ')
                            [void]$string.AppendFormat('file="{0}"',                    $caller.Location        ).Append('>')

                            Out-File -InputObject $string.ToString() @fileinfo
                        }

                        'PlainText' {
                            foreach ($line in (Split-Line -Message $logtext -Width -1)) {
                                Out-File -InputObject $timestamp.ToString('[HH:mm:ss.fff] ')    -NoNewLine  @fileinfo
                                Out-File -InputObject $Level.ToUpper(), $Space, $Tab            -NoNewLine  @fileinfo
                                Out-File -InputObject $line                                                 @fileinfo
                            }
                        }
                    }
                }

                if (-not [string]::IsNullOrWhiteSpace($LogName)) {
                    if (($PSEdition -ne 'Core') -and (Confirm-Privileges)) {
                        Write-EventLog -Message $logtext @eventinfo
                    }
                }


                if ($TeeConsole -and (($Value -le $Verbosity) -or ($PSBoundParameters.Keys -match 'Debug|Verbose'))) {
                    foreach ($line in (Split-Line -Message $logtext -Width ($Host.UI.RawUI.WindowSize.Width - 25))) {
                        Write-Host -Object $timestamp.ToString('[HH:mm:ss.fff] ')   -NoNewLine  -ForegroundColor $LogColors.TimeStamp
                        Write-Host -Object $Level.ToUpper(), $Tab                   -NoNewLine  -ForegroundColor $LogColors.Item($Level)
                        Write-Host -Object $line                                                -ForegroundColor $LogColors.Message
                    }
                }
            }

            if ($ThreadSafe) { $mutex.ReleaseMutex() }
        }
    }

    end {
        if ($ThreadSafe) { $mutex.Dispose() }
    }
}
