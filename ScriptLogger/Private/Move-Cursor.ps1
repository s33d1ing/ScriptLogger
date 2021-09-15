function Move-Cursor ([int]$X = 0, [int]$Y = 0) {
    if ($Host.Name -ne 'Windows PowerShell ISE Host') {
        $Host.UI.RawUI.CursorPosition = [System.Management.Automation.Host.Coordinates]::new(
            ($Host.UI.RawUI.CursorPosition.X + $X), ($Host.UI.RawUI.CursorPosition.Y + $Y)
        )
    }
}
