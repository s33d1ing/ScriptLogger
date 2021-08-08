filter ConvertTo-String {
    $newline = [System.Environment]::NewLine
    $string = $PSItem | Out-String -Stream

    if ([string]::IsNullOrEmpty($string)) { [string]::Empty }
    else { [string]::Join($newline, $string.TrimEnd()) }
}
