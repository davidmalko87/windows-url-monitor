# Website Availability Monitor

A lightweight PowerShell script that checks whether a website is reachable and sends an email alert when it is not.

## Features

- Checks connectivity to any hostname using `Test-NetConnection`
- Sends an email notification when the site is unreachable
- Reads credentials from environment variables — no secrets in source code
- Writes a timestamped log file for every check
- Supports TLS-enabled SMTP (port 587 by default) and plain local relays (port 25)
- Graceful error handling with descriptive exit codes

## Requirements

- Windows with PowerShell 5.1 or later
- Network access to the target host
- An SMTP server (local relay or external service such as SendGrid, Mailgun, etc.)

## Setup

### 1. Configure environment variables

Set the following environment variables before running the script. This keeps credentials out of your source code.

| Variable                  | Required | Description                               | Default     |
|---------------------------|----------|-------------------------------------------|-------------|
| `MONITOR_URL`             | Yes      | Hostname to monitor (e.g. `example.com`)  |             |
| `MONITOR_SENDER_EMAIL`    | Yes      | Email address that sends the alert        |             |
| `MONITOR_RECIPIENT_EMAIL` | Yes      | Email address that receives the alert     |             |
| `MONITOR_SENDER_PASSWORD` | No       | SMTP password for the sender account      |             |
| `MONITOR_SMTP_SERVER`     | No       | SMTP server hostname                      | `localhost` |
| `MONITOR_SMTP_PORT`       | No       | SMTP server port                          | `587`       |

**PowerShell (current session):**

```powershell
$env:MONITOR_URL             = "example.com"
$env:MONITOR_SENDER_EMAIL    = "alerts@example.com"
$env:MONITOR_RECIPIENT_EMAIL = "admin@example.com"
$env:MONITOR_SENDER_PASSWORD = "your-smtp-password"
$env:MONITOR_SMTP_SERVER     = "smtp.example.com"
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

## Scheduling with Windows Task Scheduler

To run the check automatically at regular intervals:

1. Open **Task Scheduler** and choose **Create Basic Task**.
2. Set a name such as `Website Availability Monitor`.
3. Choose the trigger interval (e.g. every 5 minutes).
4. Set the action to **Start a program**:
   - **Program:** `powershell.exe`
   - **Arguments:** `-NonInteractive -ExecutionPolicy Bypass -File "C:\path\to\Monitor-WebsiteAvailability.ps1"`
5. Ensure the task runs under an account whose environment variables are configured (see Setup above), or pass parameters directly in the Arguments field.

## Log file

Each run appends a line to `monitor.log` in the same directory as the script:

```
[2026-03-20 09:00:00] [INFO] Checking connectivity to 'example.com'...
[2026-03-20 09:00:01] [INFO] 'example.com' is accessible. No action needed.
[2026-03-20 09:05:00] [INFO] Checking connectivity to 'example.com'...
[2026-03-20 09:05:03] [WARN] 'example.com' is NOT accessible. Sending alert email to 'admin@example.com'...
[2026-03-20 09:05:04] [INFO] Alert email sent successfully.
```

Rotate or archive `monitor.log` periodically to prevent unbounded growth.

## Exit codes

| Code | Meaning                                   |
|------|-------------------------------------------|
| `0`  | Site is reachable, or alert email sent OK |
| `1`  | Configuration error or email send failure |

## Security notes

- Never commit credentials to version control. Always use environment variables or a secrets manager.
- For public SMTP services use port `587` with TLS (the default). Avoid port `25` unless you control the relay.
- Prefer application-specific passwords over your main account password where the email provider supports them.

## License

MIT
