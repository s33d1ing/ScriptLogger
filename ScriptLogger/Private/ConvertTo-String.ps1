filter ConvertTo-String {
    $newline = [System.Environment]::NewLine
    $string = $PSItem | Out-String -Stream

    if (-not [string]::IsNullOrEmpty($string)) {
        [string]::Join($newline, $string.TrimEnd())
    }
}
