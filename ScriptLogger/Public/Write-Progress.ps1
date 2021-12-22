function Write-Progress {

    <#
        .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Progress
        .ForwardHelpCategory Cmdlet
    #>

    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2097036',
        RemotingCapability = 'None'
    )]

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Activity,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,

        [Parameter(Position = 2)]
        [ValidateRange(0, 2147483647)]
        [int]$Id,

        [Parameter()]
        [ValidateRange(-1, 100)]
        [int]$PercentComplete,

        [Parameter()]
        [int]$SecondsRemaining,

        [Parameter()]
        [string]$CurrentOperation,

        [Parameter()]
        [ValidateRange(-1, 2147483647)]
        [int]$ParentId,

        [Parameter()]
        [switch]$Completed,

        [Parameter()]
        [int]$SourceId
    )


    if (-not $PSBoundParameters.ContainsKey('Id')) { $Id = 0 }
    if (-not $PSBoundParameters.ContainsKey('Status')) { $Status = 'Processing' }

    $progressRecord = [System.Management.Automation.ProgressRecord]::new($Id, $Activity, $Status)

    if ($PSBoundParameters.ContainsKey('PercentComplete')) { $progressRecord.PercentComplete = $PercentComplete }
    if ($PSBoundParameters.ContainsKey('SecondsRemaining')) { $progressRecord.SecondsRemaining = $SecondsRemaining }
    if ($PSBoundParameters.ContainsKey('CurrentOperation')) { $progressRecord.CurrentOperation = $CurrentOperation }

    if ($PSBoundParameters.ContainsKey('ParentId')) { $progressRecord.ParentActivityId = $ParentId }
    if ($PSBoundParameters.ContainsKey('Completed')) { $progressRecord.RecordType = 'Completed' }


    # Write-Output -InputObject $progressRecord

    $parameters = @{
        MessageData = $progressRecord
        Tags = 'ProgressRecord', 'ScriptLogger'
        InformationAction = 'Continue'
    }

    Write-Information @parameters
}
