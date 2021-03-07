class ScriptLogger {

    [ValidateSet('Error', 'Warning', 'Info', 'Verbose', 'Debug')]
    [string]$LogLevel = 'Info'

    [ValidateRange(-1, 65535)]
    [int]$Verbosity = 0


    ScriptLogger() { }

    ScriptLogger([string]$LogLevel, [int]$Verbosity) {
        $this.LogLevel = $LogLevel
        $this.Verbosity = $Verbosity
    }


    [void] Error([object]$Message) { $this.WriteLog('Error', [int]::new(), $Message) }
    [void] Error([int]$Value, [object]$Message) { $this.WriteLog('Error', $Value, $Message) }

    [void] Warning([object]$Message) { $this.WriteLog('Warning', [int]::new(), $Message) }
    [void] Warning([int]$Value, [object]$Message) { $this.WriteLog('Warning', $Value, $Message) }

    [void] Info([object]$Message) { $this.WriteLog('Info', [int]::new(), $Message) }
    [void] Info([int]$Value, [object]$Message) { $this.WriteLog('Info', $Value, $Message) }

    [void] Verbose([object]$Message) { $this.WriteLog('Verbose', [int]::new(), $Message) }
    [void] Verbose([int]$Value, [object]$Message) { $this.WriteLog('Verbose', $Value, $Message) }

    [void] Debug([object]$Message) { $this.WriteLog('Debug', [int]::new(), $Message) }
    [void] Debug([int]$Value, [object]$Message) { $this.WriteLog('Debug', $Value, $Message) }


    [void] WriteLog([string]$Level, [int]$Value, [object]$Message) {

        $parameters = @{
                Level = $Level
                Value = $Value
              Message = $Message

             LogLevel = $this.LogLevel
            Verbosity = $this.Verbosity
        }

        Write-Log @parameters -TeeConsole:$true
    }
}
