
if (Test-Path -Path ($path = Join-Path -Path $PSScriptRoot -ChildPath 'Public')) {
    [array]$Public = Get-ChildItem -Path $path -Filter '*.ps1' -Recurse -File
}

if (Test-Path -Path ($path = Join-Path -Path $PSScriptRoot -ChildPath 'Private')) {
    [array]$Private = Get-ChildItem -Path $path -Filter '*.ps1' -Recurse -File
}

if (Test-Path -Path ($path = Join-Path -Path $PSScriptRoot -ChildPath 'Scripts')) {
    [array]$Scripts = Get-ChildItem -Path $path -Filter '*.ps1' -Recurse -File
}


foreach ($function in (($Public + $Private) | Where-Object -Property FullName)) {
    try { Import-Module -FullyQualifiedName $function.FullName -Force }
    catch {
        Write-Warning ('Failed to import function "{0}"' -f $function.BaseName)
        Write-Host $PSItem.Exception.Message -ForegroundColor Red
    }
}

foreach ($script in ($Scripts | Where-Object -Property FullName)) {
    try { Set-Alias -Name $script.BaseName -Value $script.FullName -Force }
    catch {
        Write-Warning ('Failed to import script "{0}"' -f $script.BaseName)
        Write-Host $PSItem.Exception.Message -ForegroundColor Red
    }
}


$Aliases = Get-Alias -Definition $Public.BaseName -ErrorAction Ignore
$Module = Get-Module -FullyQualifiedName $PSCommandPath -ListAvailable

$Members = @{ 'Function' = $Public.BaseName }

if ($Aliases) { $Members['Alias'] += [array]$Aliases.Name }
if ($Scripts) { $Members['Alias'] += [array]$Scripts.BaseName }


Import-LocalizedData -BindingVariable $Module.Name
Export-ModuleMember @Members -Variable $Module.Name


$resources = Get-Variable -Name $Module.Name -ValueOnly

Set-Variable -Name 'LogColors' -Value $resources.LogColors -Force
Set-Variable -Name 'LogTypes' -Value $resources.LogTypes -Force

Set-Variable -Name 'IgnoreStrings' -Value $resources.IgnoreStrings -Force

$script:LastMessage = [System.String]::Empty
$script:WriteProgress = [System.Collections.Generic.List[System.Object]]::new()
