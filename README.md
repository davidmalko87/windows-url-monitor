# windows-url-monitor

[![CI](https://github.com/davidmalko87/windows-url-monitor/actions/workflows/ci.yml/badge.svg)](https://github.com/davidmalko87/windows-url-monitor/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-1.1.1-blue)](CHANGELOG.md)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey?logo=windows)](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
[![Last Commit](https://img.shields.io/github/last-commit/davidmalko87/windows-url-monitor)](https://github.com/davidmalko87/windows-url-monitor/commits/Prod)
[![Open Issues](https://img.shields.io/github/issues/davidmalko87/windows-url-monitor)](https://github.com/davidmalko87/windows-url-monitor/issues)

> PowerShell script that monitors a hostname's availability and fires an email alert the moment it becomes unreachable.

---

## Why?

Windows Task Scheduler can run scripts on a tight interval, but it has no built-in
alerting when a site goes down. This script fills that gap: it wraps
`Test-NetConnection` in a lightweight, credential-safe, self-logging loop that sends
an SMTP email the instant your target stops responding - no extra tooling or services
required.

---

## Features

| Feature | Description |
|---|---|
| TCP connectivity check | Uses `Test-NetConnection` to verify the target host is reachable |
| Instant email alert | Sends an SMTP message the moment the site becomes unreachable |
| Credential isolation | All secrets are read from environment variables - never hardcoded |
| Timestamped audit log | Every check is appended to `monitor.log` with `[INFO]`/`[WARN]`/`[ERROR]` severity |
| TLS support | Enables SSL automatically for non-legacy SMTP ports (587 / 465) |
| Descriptive exit codes | `0` on success, `1` on configuration or send failure |

---

## Quick Start

### 1. Clone the repository

```powershell
git clone https://github.com/davidmalko87/windows-url-monitor.git
cd windows-url-monitor
```

### 2. Configure environment variables

```powershell
$env:MONITOR_URL              = "example.com"
$env:MONITOR_SENDER_EMAIL     = "alerts@example.com"
$env:MONITOR_RECIPIENT_EMAIL  = "admin@example.com"
$env:MONITOR_SENDER_PASSWORD  = "your-smtp-password"
$env:MONITOR_SMTP_SERVER      = "smtp.example.com"
# MONITOR_SMTP_PORT defaults to 587
```

To make the settings permanent (current user):

```powershell
[System.Environment]::SetEnvironmentVariable("MONITOR_URL", "example.com", "User")
# Repeat for each variable
```

### 3. Run the script

```powershell
.\Monitor-WebsiteAvailability.ps1
```

Or pass parameters directly (useful for testing):

```powershell
.\Monitor-WebsiteAvailability.ps1 `
    -Url            "example.com" `
    -SenderEmail    "alerts@example.com" `
    -RecipientEmail "admin@example.com" `
    -SenderPassword "secret" `
    -SmtpServer     "smtp.example.com" `
    -SmtpPort       587
```

### 4. Schedule with Task Scheduler

1. Open **Task Scheduler** -> **Create Basic Task**
2. Name it (e.g. `Website Availability Monitor`)
3. Set the trigger interval (e.g. every 5 minutes)
4. **Action -> Program:** `powershell.exe`
   **Arguments:** `-NonInteractive -ExecutionPolicy Bypass -File "C:\path\to\Monitor-WebsiteAvailability.ps1"`
5. Run the task under the account whose environment variables are configured

---

## Configuration reference

| Variable | Required | Description | Default |
|---|---|---|---|
| `MONITOR_URL` | Yes | Hostname to monitor (e.g. `example.com`) | - |
| `MONITOR_SENDER_EMAIL` | Yes | Email address that sends the alert | - |
| `MONITOR_RECIPIENT_EMAIL` | Yes | Email address that receives the alert | - |
| `MONITOR_SENDER_PASSWORD` | No | SMTP password for the sender account | - |
| `MONITOR_SMTP_SERVER` | No | SMTP server hostname | `localhost` |
| `MONITOR_SMTP_PORT` | No | SMTP server port | `587` |

---

## Log output

Each run appends a line to `monitor.log` in the script directory:

```
[2026-03-20 09:00:00] [INFO] Checking connectivity to 'example.com'...
[2026-03-20 09:00:01] [INFO] 'example.com' is accessible. No action needed.
[2026-03-20 09:05:03] [WARN] 'example.com' is NOT accessible. Sending alert email to 'admin@example.com'...
[2026-03-20 09:05:04] [INFO] Alert email sent successfully.
```

> Rotate or archive `monitor.log` periodically to prevent unbounded growth.

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Site is reachable, or alert email sent successfully |
| `1` | Configuration error or email send failure |

---

## Project structure

```
windows-url-monitor/
├── Monitor-WebsiteAvailability.ps1  # Main monitoring script
├── windows-url-monitor.psd1         # Manifest - canonical version source
├── PSScriptAnalyzerSettings.psd1    # Linter configuration
├── CHANGELOG.md                     # Version history
├── CONTRIBUTING.md                  # Contribution guide and semver policy
├── LICENSE                          # MIT licence
└── README.md                        # This file
```

---

## Known limitations

- Uses `Test-NetConnection` (TCP reachability), not HTTP - a server returning `500` or a redirect loop will still appear "up"
- No retry logic - a single transient packet loss triggers an alert immediately
- Monitors one endpoint per script instance; for multiple URLs, schedule one instance per target

---

## Security notes

- Never commit credentials to version control - always use environment variables
- Use port 587 with TLS for public SMTP services
- Prefer app-specific passwords over your main account password where supported

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the semver policy and the two-file update rule.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a full version history.

## License

[MIT](LICENSE) © 2023 David Malko
