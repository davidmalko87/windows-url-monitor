<#
.SYNOPSIS
    Monitors website accessibility and sends an email alert when the site is unreachable.

.DESCRIPTION
    This script checks whether a specified URL is reachable using Test-NetConnection.
    If the site is down, it sends an email notification via SMTP.

    Credentials are read from environment variables to keep sensitive data out of
    source control. A log file is written so every check is auditable.

.PARAMETER Url
    The hostname or URL to monitor. Defaults to the MONITOR_URL environment variable.

.PARAMETER SenderEmail
    The email address used to send the alert. Defaults to MONITOR_SENDER_EMAIL.

.PARAMETER RecipientEmail
    The email address that receives the alert. Defaults to MONITOR_RECIPIENT_EMAIL.

.PARAMETER SenderPassword
    The SMTP password for the sender account. Defaults to MONITOR_SENDER_PASSWORD.

.PARAMETER SmtpServer
    The SMTP server hostname. Defaults to MONITOR_SMTP_SERVER (fallback: localhost).

.PARAMETER SmtpPort
    The SMTP server port. Defaults to MONITOR_SMTP_PORT (fallback: 587).

.PARAMETER LogFile
    Path to the log file. Defaults to 'monitor.log' in the script directory.

.EXAMPLE
    # Run with environment variables pre-set
    .\Monitor-WebsiteAvailability.ps1

.EXAMPLE
    # Run with explicit parameters
    .\Monitor-WebsiteAvailability.ps1 -Url "example.com" -SmtpServer "smtp.example.com"

.EXAMPLE
    # Set required environment variables and run
    $env:MONITOR_URL             = "example.com"
    $env:MONITOR_SENDER_EMAIL    = "alerts@example.com"
    $env:MONITOR_RECIPIENT_EMAIL = "admin@example.com"
    $env:MONITOR_SENDER_PASSWORD = "secret"
    $env:MONITOR_SMTP_SERVER     = "smtp.example.com"
    .\Monitor-WebsiteAvailability.ps1

.NOTES
    Requires PowerShell 5.1 or later on Windows.
    Schedule this script with Windows Task Scheduler to run at regular intervals.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPlainTextForPassword', 'SenderPassword',
    Justification = 'Password is sourced from the MONITOR_SENDER_PASSWORD environment variable. No plain-text credential is ever hardcoded in source.')]
[CmdletBinding()]
param (
    [string]$Url            = $env:MONITOR_URL,
    [string]$SenderEmail    = $env:MONITOR_SENDER_EMAIL,
    [string]$RecipientEmail = $env:MONITOR_RECIPIENT_EMAIL,
    [string]$SenderPassword = $env:MONITOR_SENDER_PASSWORD,
    [string]$SmtpServer     = $(if ($env:MONITOR_SMTP_SERVER) { $env:MONITOR_SMTP_SERVER } else { 'localhost' }),
    [int]   $SmtpPort       = $(if ($env:MONITOR_SMTP_PORT)   { [int]$env:MONITOR_SMTP_PORT } else { 587 }),
    [string]$LogFile        = (Join-Path $PSScriptRoot 'monitor.log')
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-MonitorLog {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"
    Write-Output $line
    Add-Content -Path $script:LogFile -Value $line
}

function Assert-Required {
    param([string]$Value, [string]$Name)
    if (-not $Value) {
        Write-MonitorLog "Required parameter '$Name' is not set. Set the corresponding environment variable or pass it as a parameter." -Level ERROR
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Validate required inputs
# ---------------------------------------------------------------------------

Assert-Required $Url            'Url (MONITOR_URL)'
Assert-Required $SenderEmail    'SenderEmail (MONITOR_SENDER_EMAIL)'
Assert-Required $RecipientEmail 'RecipientEmail (MONITOR_RECIPIENT_EMAIL)'

# ---------------------------------------------------------------------------
# Check connectivity
# ---------------------------------------------------------------------------

Write-MonitorLog "Checking connectivity to '$Url'..."

$isReachable = $false
try {
    $result = Test-NetConnection -ComputerName $Url -InformationLevel Quiet -ErrorAction Stop
    $isReachable = [bool]$result
} catch {
    Write-MonitorLog "Test-NetConnection threw an exception: $_" -Level WARN
    $isReachable = $false
}

if ($isReachable) {
    Write-MonitorLog "'$Url' is accessible. No action needed."
    exit 0
}

# ---------------------------------------------------------------------------
# Site is down - send alert email
# ---------------------------------------------------------------------------

Write-MonitorLog "'$Url' is NOT accessible. Sending alert email to '$RecipientEmail'..." -Level WARN

$subject = "ALERT: $Url is unreachable"
$body    = @"
This is an automated monitoring alert.

Website : $Url
Status  : Unreachable
Time    : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')

Please investigate as soon as possible.
"@

try {
    $message         = New-Object -TypeName System.Net.Mail.MailMessage -ArgumentList $SenderEmail, $RecipientEmail
    $message.Subject = $subject
    $message.Body    = $body

    $smtp            = New-Object -TypeName System.Net.Mail.SmtpClient -ArgumentList $SmtpServer, $SmtpPort
    $smtp.EnableSsl  = ($SmtpPort -ne 25)   # enable TLS for non-legacy ports

    if ($SenderPassword) {
        $smtp.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList $SenderEmail, $SenderPassword
    }

    $smtp.Send($message)
    Write-MonitorLog "Alert email sent successfully."
} catch {
    Write-MonitorLog "Failed to send alert email: $_" -Level ERROR
    exit 1
}
