function Get-ScreenBuffer {

    param (
        [int]$Left = 0,
        [int]$Top = 0,
        [int]$Right = $Host.UI.RawUI.BufferSize.Width - 1,
        [int]$Bottom = $Host.UI.RawUI.CursorPosition.Y
    )

    if (($Host.Name -ne 'Windows PowerShell ISE Host') -and ($PSVersionTable.Platform -ne 'Unix')) {
        $rectangle = [System.Management.Automation.Host.Rectangle]::new($Left, $Top, $Right, $Bottom)
        $buffer = $Host.UI.RawUI.GetBufferContents($rectangle)

        if ($buffer.Character) { [string]::new($buffer.Character) }
    }
}
