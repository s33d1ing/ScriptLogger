function New-Log {

    <#
        .ForwardHelpTargetName ScriptLogger\Write-Log
        .ForwardHelpCategory Cmdlet
    #>

    [Alias('InitLog')]
    [CmdletBinding(DefaultParameterSetName = 'Console')]

    param (
        [Parameter()]
        [switch]$CreateEnvironmentVariables
    )

    DynamicParam {
        $constants = Get-Command -Name Write-Log | ForEach-Object { $PSItem.Parameters.Values } | Where-Object {
            $PSItem.Attributes | Where-Object { ($PSItem.TypeId.Name -eq 'ScriptLoggerAttribute') } |
                Where-Object { ($PSItem.ParameterType -eq 'Constant') -or $PSItem.Constant }
        }

        $dictionary = Import-DynamicParameters -CommandName 'Write-Log' -Include $constants.Name
        $dictionary.GetEnumerator() | ForEach-Object { Set-Variable -Name $PSItem.Value.Name -Value $PSItem.Value.Value }

        $dictionary
    }

    begin {
        $PSBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name $PSItem.Key -Value $PSItem.Value }

        if ((-not [string]::IsNullOrWhiteSpace($LogName)) -and (($PSEdition -eq 'Core') -or (-not (Confirm-Privileges)))) {
            Write-Warning 'You must have Administrative Privileges in order to write to the Windows Event Log'
        }
    }

    end {
        $parameters = Get-ParameterValues -Cmdlet $PSCmdlet -ParameterSet $PSCmdlet.ParameterSetName

        if ($CreateEnvironmentVariables) {
            $parameters.GetEnumerator() | ForEach-Object {
                $path = Join-Path -Path 'env:' -ChildPath $PSItem.Key.ToUpper()

                Set-Item -Path $path -Value $PSItem.Value -Force
            }
        }

        $parameters
    }
}
