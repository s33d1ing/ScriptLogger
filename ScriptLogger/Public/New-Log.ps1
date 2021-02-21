function New-Log {

    <#
        .ForwardHelpTargetName ScriptLogger\Write-Log
        .ForwardHelpCategory Function
    #>

    [Alias('InitLog')]
    [CmdletBinding(DefaultParameterSetName = 'Console')]

    param (
        [Parameter()]
        [switch]$CreateEnvironmentVariables
    )

    DynamicParam {
        $exclude = 'Level', 'Value', 'Message', 'EventId', 'EventCategory', 'ForceRotate'
        $dictionary = Import-DynamicParameters -CommandName 'Write-Log' -Exclude $exclude

        #* Create a variable for each imported parameter because runtime defined parameters do not automatically assign one
        $dictionary.GetEnumerator() | ForEach-Object { Set-Variable -Name $PSItem.Value.Name -Value $PSItem.Value.Value }

        $dictionary
    }

    begin {
        #* Create a variable for each bound parameter because dynamic parameters do not automatically assign one
        $PSBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name $PSItem.Key -Value $PSItem.Value }

        if ((-not [string]::IsNullOrWhiteSpace($LogName)) -and (-not (Confirm-Privileges))) {
            Write-Warning 'You must have Administrative Privileges in order to write to the Windows Event Log'
        }
    }

    end {
        $parameters = Get-ParameterValues -Cmdlet $PSCmdlet -ParameterSet $PSCmdlet.ParameterSetName

        if ($CreateEnvironmentVariables) {
            $parameters.GetEnumerator() | ForEach-Object {
                Set-Item -Path (Join-Path -Path 'env:' -ChildPath $PSItem.Key.ToUpper()) -Value $PSItem.Value -Force
            }
        }

        $parameters
    }
}
