function Import-DynamicParameters {
    [CmdletBinding()]
    param(
        [Alias('Name')]
        [Parameter(Mandatory = $true)]
        [string]$CommandName,

        [Parameter()]
        [string[]]$Include,

        [Parameter()]
        [string[]]$Exclude
    )

    $common = [System.Management.Automation.PSCmdlet]::CommonParameters

    $dictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
    $parameters = Get-Command -Name $CommandName | Select-Object -ExpandProperty Parameters

    $defaults = Get-Help -Name $CommandName | Select-Object -ExpandProperty Parameters |
        Select-Object -ExpandProperty Parameter | Select-Object -Property Name, DefaultValue

    $parameters.GetEnumerator() | Where-Object -Property Key -NotIn $common | ForEach-Object {
        if (((-not $Exclude) -or ($PSItem.Key -notin $Exclude)) -and ((-not $Include) -or ($PSItem.Key -in $Include))) {

            $parameter = [System.Management.Automation.RuntimeDefinedParameter]::new(
                $PSItem.Value.Name, $PSItem.Value.ParameterType, $PSItem.Value.Attributes
            )

            $parameter.Value = $defaults | Where-Object -Property Name -EQ $parameter.Name |
                Where-Object -Property DefaultValue | Select-Object -ExpandProperty DefaultValue

            $dictionary[$PSItem.Key] = $parameter
        }
    }

    $dictionary
}
