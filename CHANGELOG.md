# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-03-27

### Added
- `windows-url-monitor.psd1` manifest as the single canonical source of the version number
- `CHANGELOG.md`, `CONTRIBUTING.md`, and `LICENSE` files
- GitHub Actions CI workflow (PSScriptAnalyzer lint + syntax check on Ubuntu and Windows)
- Dependabot configuration for automatic GitHub Actions and NuGet/PSGallery updates
- GitHub Issue templates (bug report, feature request) and Pull Request template
- `PSScriptAnalyzerSettings.psd1` to suppress the cross-platform-incompatible BOM rule

### Changed
- Improved README with Shields.io badges, Features table, Why? section, Quick Start,
  project structure tree, and known limitations
- Renamed `Write-Log` to `Write-MonitorLog` to avoid conflict with a cmdlet exported
  by pre-installed modules on the CI runner (`PSAvoidOverwritingBuiltInCmdlets`)
- Used `$script:LogFile` inside `Write-MonitorLog` so PSScriptAnalyzer tracks the
  parameter as used across scopes (`PSReviewUnusedParameter`)
- `New-Object` calls updated to use explicit `-TypeName` / `-ArgumentList` parameters
  (`PSAvoidUsingPositionalParameters`)
- Added `[Diagnostics.CodeAnalysis.SuppressMessageAttribute]` for `PSAvoidUsingPlainTextForPassword`
  with a justification comment

## [1.1.0] - 2026-03-20

### Added
- Comprehensive comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`)
- Environment variable fallback defaults for `SmtpServer` (`localhost`) and `SmtpPort` (`587`)
- Graceful error handling with descriptive exit codes (`0` = success, `1` = configuration or send failure)
- TLS auto-detection: SSL is enabled automatically for all non-legacy SMTP ports

### Changed
- Refactored script into clearly separated sections: helpers, validation, connectivity check, alert
- Improved log format with `[INFO]`, `[WARN]`, `[ERROR]` severity levels
- `Write-Log` now writes to both stdout and the log file simultaneously

## [1.0.0] - 2023-03-30

### Added
- Initial release: monitors a hostname using `Test-NetConnection`
- Sends an SMTP email alert when the target is unreachable
- Writes timestamped entries to `monitor.log`
- Reads all credentials from environment variables
