function Get-ParameterValues {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Management.Automation.PSCmdlet]
        ${Cmdlet} = (Get-Variable -Name PSCmdlet -ValueOnly -Scope 1),

        [Parameter()]
        [string]$ParameterSet
    )

    $dictionary = [System.Collections.Specialized.OrderedDictionary]::new()

    $Cmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        if ((-not $ParameterSet) -or ($PSItem.Value.Attributes.ParameterSetName -like $ParameterSet)) {

            if ($variable = Get-Variable -Name $PSItem.Key -Scope 1 -ErrorAction Ignore) {
                if ($variable.Value -and ($variable.Value -ne ($null -as $PSItem.Value.ParameterType))) {
                    $dictionary[$PSItem.Key] = $variable.Value -as $PSItem.Value.ParameterType
                }
            }

            if ($Cmdlet.MyInvocation.BoundParameters.ContainsKey($PSItem.Key)) {
                $dictionary[$PSItem.Key] = $Cmdlet.MyInvocation.BoundParameters[$PSItem.Key]
            }
        }
    }

    $dictionary
}
