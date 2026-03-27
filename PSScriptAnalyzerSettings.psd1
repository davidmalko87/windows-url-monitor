# PSScriptAnalyzer settings for windows-url-monitor.
# Reference this file with: Invoke-ScriptAnalyzer -Settings ./PSScriptAnalyzerSettings.psd1
@{
    # PSUseBOMForUnicodeEncodedFile is a Windows-centric style preference.
    # UTF-8 without BOM is the cross-platform default and is handled correctly
    # by PowerShell 6+ and all modern editors. Suppressed to keep the workflow
    # portable across Linux and Windows CI runners.
    ExcludeRules = @('PSUseBOMForUnicodeEncodedFile')
}
