#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }

$ModuleManifestName = 'ScriptLogger.psd1'
$ModuleManifestPath = '{0}\..\ScriptLogger\{1}' -f $PSScriptRoot, $ModuleManifestName

Import-Module -FullyQualifiedName $ModuleManifestPath -Force

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}
