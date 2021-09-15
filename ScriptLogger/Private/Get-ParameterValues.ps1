function Get-ParameterValues {

    param (
        [Parameter()]
        [System.Management.Automation.PSCmdlet]
        ${Cmdlet} = (Get-Variable -Name 'PSCmdlet' -ValueOnly -Scope 1),

        [Parameter()]
        [string]$ParameterSet,

        [Parameter()]
        [string[]]$Include,

        [Parameter()]
        [string[]]$Exclude
    )

    $dictionary = [System.Collections.Specialized.OrderedDictionary]::new()

    $Cmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        if ((-not $ParameterSet) -or ($PSItem.Value.Attributes.ParameterSetName -like $ParameterSet)) {
            if (((-not $Exclude) -or ($PSItem.Key -notin $Exclude)) -and ((-not $Include) -or ($PSItem.Key -in $Include))) {

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
    }

    $dictionary
}
