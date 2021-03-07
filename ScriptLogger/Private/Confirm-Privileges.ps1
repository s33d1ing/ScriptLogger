function Confirm-Privileges {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    $administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    $principal.IsInRole($administrator)
}
