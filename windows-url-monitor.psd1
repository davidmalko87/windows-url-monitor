# Script manifest - single source of truth for version and metadata.
# Read with: Import-PowerShellDataFile .\windows-url-monitor.psd1
@{
    ModuleVersion     = '1.1.1'
    GUID              = 'a3b4c5d6-e7f8-4a9b-8c0d-1e2f3a4b5c6d'
    Author            = 'David Malko'
    CompanyName       = 'David Malko'
    Copyright         = '(c) 2026 David Malko. All rights reserved.'
    Description       = 'Monitors website accessibility and sends an email alert when the target becomes unreachable.'
    PowerShellVersion = '5.1'

    PrivateData = @{
        PSData = @{
            Tags       = @('monitoring', 'availability', 'smtp', 'alert', 'windows', 'task-scheduler')
            LicenseUri = 'https://github.com/davidmalko87/windows-url-monitor/blob/Prod/LICENSE'
            ProjectUri = 'https://github.com/davidmalko87/windows-url-monitor'
        }
    }
}
