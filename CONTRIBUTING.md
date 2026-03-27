# Contributing

Thank you for considering a contribution to **windows-url-monitor**!

## Versioning policy

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

| Change type | Version component | Example |
|---|---|---|
| Backwards-incompatible change (parameter removed/renamed, behaviour change) | **MAJOR** | `1.1.1` -> `2.0.0` |
| New backwards-compatible feature or enhancement | **MINOR** | `1.1.1` -> `1.2.0` |
| Bug fix, documentation correction, or lint/style clean-up | **PATCH** | `1.1.1` -> `1.1.2` |

## Two-file update rule

**Every pull request that changes behaviour or adds a feature must update both:**

1. `windows-url-monitor.psd1` - bump `ModuleVersion` to the new semver value
2. `CHANGELOG.md` - add a new `## [x.y.z] - YYYY-MM-DD` section describing what changed

PRs that modify only documentation or CI infrastructure are exempt from the version bump
but must still add a `CHANGELOG.md` entry if user-visible behaviour is affected.

## Development workflow

1. Fork the repository and create a branch from `Prod`:
   ```powershell
   git checkout -b feature/my-improvement Prod
   ```

2. Make your changes.

3. Run PSScriptAnalyzer locally to catch linter issues before pushing:
   ```powershell
   Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
   Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1 -Severity Error, Warning
   ```

4. Verify the script syntax parses without errors:
   ```powershell
   $tokens = $null; $errors = $null
   $null = [System.Management.Automation.Language.Parser]::ParseFile(
       (Resolve-Path .\Monitor-WebsiteAvailability.ps1),
       [ref]$tokens,
       [ref]$errors
   )
   $errors   # should be empty
   ```

5. Bump `ModuleVersion` in `windows-url-monitor.psd1` and add a `CHANGELOG.md` entry.

6. Open a pull request against `Prod` and fill in the PR template.

## Code style

- Follow the [PowerShell Best Practices and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Use approved PowerShell verbs for function names (`Get-Help about_Verbs`)
- Prefer named parameters over positional parameters
- No plain-text passwords in source - always read credentials from environment variables

## Reporting issues

Please use the [GitHub Issue templates](.github/ISSUE_TEMPLATE/) to report bugs
or request features.
