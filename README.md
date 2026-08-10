# Visual Studio Code Extensions Toolkit

A practical, privacy-safe reference and automation toolkit for **Visual Studio Code extension installation, backup, restore, inventory, local storage, VSIX packages, Extension API development, security, and troubleshooting**.

The repository includes a portable JSON inventory of the extension set plus matching **PowerShell** and **Bash** tools. No real Windows username, employee ID, workstation path, hostname, internal IP, token, or other machine-specific personal data is stored in the portable inventory.

## Repository layout

```text
VisualStudioCode/
├── README.md
├── extensions.json
├── scripts/
│   ├── Get-VSCodeExtensions.ps1
│   ├── get-vscode-extensions.sh
│   ├── Export-VSCodeExtensions.ps1
│   ├── export-vscode-extensions.sh
│   ├── Install-VSCodeExtensions.ps1
│   └── install-vscode-extensions.sh
└── examples/
    └── minimal-extension/
        ├── package.json
        └── extension.js
```

## Portable extension inventory

`extensions.json` contains **83 extension IDs and their recorded versions**.

It intentionally keeps only portable information:

```json
{
  "schemaVersion": 1,
  "installDefault": "latest",
  "extensions": [
    {
      "id": "publisher.extension",
      "version": "1.0.0"
    }
  ]
}
```

The raw VS Code `extensions.json` from a workstation should **not** be committed because it can contain local filesystem paths, UUIDs, installation timestamps, and other machine-specific metadata.

---

# Install the complete extension set

## Windows - PowerShell

Clone the repository:

```powershell
git clone https://github.com/Motaibi1989/VisualStudioCode.git
cd VisualStudioCode
.\scripts\Install-VSCodeExtensions.ps1
```

The default mode installs the latest Marketplace version and skips extensions already installed.

Install the recorded versions instead:

```powershell
.\scripts\Install-VSCodeExtensions.ps1 -Pinned
```

Force reinstall/check every extension:

```powershell
.\scripts\Install-VSCodeExtensions.ps1 -Force
```

## Windows - install from anywhere without cloning

```powershell
$base = "https://raw.githubusercontent.com/Motaibi1989/VisualStudioCode/main"
$temp = Join-Path $env:TEMP "vscode-extension-toolkit"

New-Item -ItemType Directory -Force -Path $temp | Out-Null

Invoke-WebRequest "$base/extensions.json" `
    -OutFile "$temp/extensions.json"

Invoke-WebRequest "$base/scripts/Install-VSCodeExtensions.ps1" `
    -OutFile "$temp/Install-VSCodeExtensions.ps1"

& "$temp/Install-VSCodeExtensions.ps1" `
    -Config "$temp/extensions.json"
```

## Linux / macOS - Bash

```bash
git clone https://github.com/Motaibi1989/VisualStudioCode.git
cd VisualStudioCode
bash scripts/install-vscode-extensions.sh
```

Install the recorded versions:

```bash
bash scripts/install-vscode-extensions.sh extensions.json pinned
```

## Linux / macOS - install from anywhere without cloning

```bash
BASE="https://raw.githubusercontent.com/Motaibi1989/VisualStudioCode/main"
TMP="$(mktemp -d)"

curl -fsSL "$BASE/extensions.json" \
  -o "$TMP/extensions.json"

curl -fsSL "$BASE/scripts/install-vscode-extensions.sh" \
  -o "$TMP/install-vscode-extensions.sh"

bash "$TMP/install-vscode-extensions.sh" "$TMP/extensions.json"
```

The Bash installer requires `python3` to parse JSON.

---

# Export your current extension set

Use these scripts after adding or removing extensions so `extensions.json` can be refreshed without exposing personal paths.

## PowerShell

```powershell
.\scripts\Export-VSCodeExtensions.ps1
```

Custom output file:

```powershell
.\scripts\Export-VSCodeExtensions.ps1 -Output .\my-extensions.json
```

## Bash

```bash
bash scripts/export-vscode-extensions.sh
```

Custom output file:

```bash
bash scripts/export-vscode-extensions.sh ./my-extensions.json
```

Both exporters use:

```text
code --list-extensions --show-versions
```

and create a sanitized portable JSON file containing only extension IDs and versions.

---

# List installed extensions

## VS Code CLI

```bash
code --list-extensions
```

With versions:

```bash
code --list-extensions --show-versions
```

## PowerShell inventory

```powershell
.\scripts\Get-VSCodeExtensions.ps1
```

This inspects extension manifests under the local extension folders and can show fields such as name, ID, version, publisher, entry point, commands, and path.

## Bash inventory

```bash
bash scripts/get-vscode-extensions.sh
```

---

# Extension locations

VS Code installs user extensions in a per-user directory.

| Platform | Default path |
|---|---|
| Windows | `%USERPROFILE%\.vscode\extensions` |
| macOS | `~/.vscode/extensions` |
| Linux | `~/.vscode/extensions` |

Windows PowerShell:

```powershell
Set-Location "$env:USERPROFILE\.vscode\extensions"
```

Bash:

```bash
cd "$HOME/.vscode/extensions"
```

Generic Windows expanded form:

```text
C:\Users\<USERNAME>\.vscode\extensions
```

Never hard-code a real username or employee/account identifier in public documentation.

---

# What is inside the extensions folder?

Typical layout:

```text
.vscode/extensions/
├── publisher.extension-name-version/
│   ├── package.json
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── extension.js / dist / out
│   └── other extension files
├── .obsolete
└── extensions.json
```

`package.json` is the extension manifest and can define:

```text
name
publisher
version
engines.vscode
main / browser
activationEvents
contributes.commands
contributes.menus
contributes.views
contributes.configuration
contributes.keybindings
contributes.languages
contributes.themes
contributes.debuggers
```

`.obsolete` is used by VS Code during extension update/removal housekeeping. Avoid manually deleting VS Code-managed metadata while the application is running.

---

# Install and remove individual extensions

PowerShell or Bash:

```bash
code --install-extension publisher.extension
```

Specific version:

```bash
code --install-extension publisher.extension@1.0.0
```

Uninstall:

```bash
code --uninstall-extension publisher.extension
```

---

# VSIX / offline installation

Install a local VSIX package:

```bash
code --install-extension myextension.vsix
```

Or in VS Code:

```text
Ctrl+Shift+X
Extensions menu
Install from VSIX...
```

VSIX packages are useful for offline machines, internal extensions, development builds, and controlled deployments.

---

# Extension management filters

Useful filters in the Extensions view:

```text
@installed
@enabled
@disabled
@builtin
@deprecated
@recommended
@updates
@workspaceUnsupported
@category:themes
@category:formatters
@category:linters
@category:snippets
```

Example:

```text
@installed @category:themes
```

---

# Custom extension directory

VS Code can use another extension folder:

```bash
code --extensions-dir "/path/to/vscode/extensions"
```

Windows example using a generic drive:

```powershell
code --extensions-dir "D:\VSCode\Extensions"
```

For normal synchronization between computers, Settings Sync or this repository's portable JSON approach is generally cleaner than copying the entire `.vscode/extensions` directory.

---

# Minimal extension development

A minimal extension can contain:

```text
my-extension/
├── package.json
└── extension.js
```

Example JavaScript:

```javascript
const vscode = require('vscode');

function activate(context) {
    const command = vscode.commands.registerCommand(
        'myTools.showProjectInfo',
        () => {
            const editor = vscode.window.activeTextEditor;

            if (!editor) {
                vscode.window.showWarningMessage('No file is currently open.');
                return;
            }

            vscode.window.showInformationMessage(
                `File: ${editor.document.fileName} | Language: ${editor.document.languageId}`
            );
        }
    );

    context.subscriptions.push(command);
}

function deactivate() {}

module.exports = { activate, deactivate };
```

The repository includes a working minimal example under `examples/minimal-extension/`.

---

# Extension API capabilities

| Area | API / capability | Example |
|---|---|---|
| Commands | `vscode.commands` | Custom commands |
| Editor | `vscode.window.activeTextEditor` | Read/change active files |
| Workspace | `vscode.workspace` | Workspace configuration |
| Files | `vscode.workspace.fs` | File operations |
| Terminal | `createTerminal()` | Command workflows |
| Diagnostics | Language API | Errors/warnings |
| Status bar | `createStatusBarItem()` | Tool status |
| Tree views | Tree Data Provider | Custom sidebar |
| Webviews | Webview API | HTML/CSS/JS UI |
| Tasks | `vscode.tasks` | Build/deployment tasks |
| Debugging | Debug API | Debug workflows |
| Languages | Language APIs | Completion/hover/formatting |
| Secrets | `context.secrets` | Secure secret storage |
| Themes | Contribution points | Color/icon themes |

---

# Security and privacy

Treat extensions as executable software.

Do not commit values such as:

```text
C:\Users\<REAL_USERNAME>\...
employee/account IDs
computer names
internal domains
internal IP addresses
email addresses
access tokens
API keys
passwords
secrets
raw workstation configuration containing local metadata
```

Prefer portable forms:

```text
%USERPROFILE%\.vscode\extensions
$env:USERPROFILE\.vscode\extensions
$HOME/.vscode/extensions
C:\Users\<USERNAME>\.vscode\extensions
<HOSTNAME>
<DOMAIN>
<IP_ADDRESS>
```

Before installing an extension, review the publisher and source. Remove unused extensions and keep active extensions updated.

---

# Troubleshooting

Check the active extension set:

```bash
code --list-extensions --show-versions
```

If an extension does not load:

```text
View → Output
Log (Extension Host)
Developer: Show Running Extensions
Developer: Reload Window
```

Prefer uninstalling through the CLI instead of deleting extension directories manually:

```bash
code --uninstall-extension publisher.extension
```

---

# Official references

- Extension Marketplace: https://code.visualstudio.com/docs/configure/extensions/extension-marketplace
- Extension API: https://code.visualstudio.com/api
- Extension samples: https://github.com/microsoft/vscode-extension-samples
- Extension manifest: https://code.visualstudio.com/api/references/extension-manifest
- Contribution points: https://code.visualstudio.com/api/references/contribution-points
- VS Code API: https://code.visualstudio.com/api/references/vscode-api
- Extension security: https://code.visualstudio.com/docs/configure/extensions/extension-runtime-security

## Goal

Provide a reusable VS Code extension management and development toolkit that works across machines and operating systems while keeping workstation-specific and personal information out of the public repository.
