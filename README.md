# windows-url-monitor

> PowerShell script that monitors URL availability and sends an email alert the moment a site becomes unreachable.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey?logo=windows)

## What It Does

Checks whether a hostname is reachable using `Test-NetConnection`, logs every check to a timestamped file, and sends an email alert via SMTP when the target is down. Credentials are read from environment variables — no secrets in source code.

## Features

- Checks connectivity to any hostname using `Test-NetConnection`
- Sends an email notification the moment the site is unreachable
- Reads all credentials from environment variables — safe to commit
- Writes a timestamped log entry for every check
- Supports TLS-enabled SMTP (port 587) and plain local relays (port 25)
- Graceful error handling with descriptive exit codes

## Requirements

- Windows with PowerShell 5.1 or later
- Network access to the target host
- An SMTP server (local relay or external such as SendGrid, Mailgun, etc.)

## Setup

### 1. Set environment variables

| Variable | Required | Description | Default |
|---|---|---|---|
| `MONITOR_URL` | ✅ | Hostname to monitor (e.g. `example.com`) | — |
| `MONITOR_SENDER_EMAIL` | ✅ | Email address that sends the alert | — |
| `MONITOR_RECIPIENT_EMAIL` | ✅ | Email address that receives the alert | — |
| `MONITOR_SENDER_PASSWORD` | No | SMTP password for the sender account | — |
| `MONITOR_SMTP_SERVER` | No | SMTP server hostname | `localhost` |
| `MONITOR_SMTP_PORT` | No | SMTP server port | `587` |

**Current session:**

```powershell
$env:MONITOR_URL              = "example.com"
$env:MONITOR_SENDER_EMAIL     = "alerts@example.com"
$env:MONITOR_RECIPIENT_EMAIL  = "admin@example.com"
$env:MONITOR_SENDER_PASSWORD  = "your-smtp-password"
$env:MONITOR_SMTP_SERVER      = "smtp.example.com"
```

**Permanently (user scope):**

```powershell
[System.Environment]::SetEnvironmentVariable("MONITOR_URL", "example.com", "User")
# Repeat for each variable
```

### 2. Run the script

```powershell
.\Monitor-WebsiteAvailability.ps1
```

Or pass parameters directly (useful for testing):

```powershell
.\Monitor-WebsiteAvailability.ps1 `
    -Url             "example.com" `
    -SenderEmail     "alerts@example.com" `
    -RecipientEmail  "admin@example.com" `
    -SenderPassword  "secret" `
    -SmtpServer      "smtp.example.com" `
    -SmtpPort        587
```

## Scheduling with Task Scheduler

1. Open **Task Scheduler** and choose **Create Basic Task**
2. Set a name such as `Website Availability Monitor`
3. Choose a trigger interval (e.g., every 5 minutes)
4. Set the action: **Program:** `powershell.exe` | **Arguments:** `-NonInteractive -ExecutionPolicy Bypass -File "C:\path\to\Monitor-WebsiteAvailability.ps1"`
5. Ensure the task runs under the account whose environment variables are configured

## Log File

Each run appends a line to `monitor.log` in the same directory:

```
[2026-03-20 09:00:00] [INFO] Checking connectivity to 'example.com'...
[2026-03-20 09:00:01] [INFO] 'example.com' is accessible. No action needed.
[2026-03-20 09:05:03] [WARN] 'example.com' is NOT accessible. Sending alert email...
[2026-03-20 09:05:04] [INFO] Alert email sent successfully.
```

> Rotate or archive `monitor.log` periodically to prevent unbounded growth.

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Site is reachable, or alert email sent successfully |
| `1` | Configuration error or email send failure |

## Security Notes

- Never commit credentials to version control — always use environment variables
- Use port 587 with TLS for public SMTP services
- Prefer app-specific passwords over your main account password where supported

## License

[MIT](LICENSE) © 2026 David Malko
