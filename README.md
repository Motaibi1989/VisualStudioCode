# Visual Studio Code Extensions Reference

A practical reference for **Visual Studio Code extension installation, management, local storage, VSIX packages, Extension API development, security, and troubleshooting**.

This repository combines official VS Code guidance with generic, reusable examples and PowerShell commands. Examples intentionally avoid personal usernames, employee IDs, workstation names, and other identifying data.

## Contents

1. [Extension locations](#extension-locations)
2. [What is inside the extensions folder](#what-is-inside-the-extensions-folder)
3. [List installed extensions](#list-installed-extensions)
4. [Install and uninstall extensions](#install-and-uninstall-extensions)
5. [VSIX offline installation](#vsix-offline-installation)
6. [Extension management in VS Code](#extension-management-in-vs-code)
7. [Changing the extensions directory](#changing-the-extensions-directory)
8. [Extension anatomy](#extension-anatomy)
9. [Extension API capabilities](#extension-api-capabilities)
10. [Local extension development](#local-extension-development)
11. [PowerShell inventory](#powershell-inventory)
12. [Security](#security)
13. [Troubleshooting](#troubleshooting)
14. [References](#references)

---

## Extension locations

VS Code installs user extensions in a per-user extensions directory.

| Platform | Default path |
|---|---|
| Windows | `%USERPROFILE%\.vscode\extensions` |
| macOS | `~/.vscode/extensions` |
| Linux | `~/.vscode/extensions` |

### Windows

```powershell
cd "$env:USERPROFILE\.vscode\extensions"
dir
```

Generic expanded form:

```text
C:\Users\<USERNAME>\.vscode\extensions
```

Prefer environment variables in scripts and documentation so no actual account name or identifier is exposed.

Open the directory in Explorer:

```powershell
explorer "$env:USERPROFILE\.vscode\extensions"
```

Open it in VS Code:

```powershell
code "$env:USERPROFILE\.vscode\extensions"
```

---

## What is inside the extensions folder

Typical layout:

```text
.vscode\extensions\
├── publisher.extension-name-version\
│   ├── package.json
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── extension.js / dist / out
│   └── other extension files
├── .obsolete
└── extensions.json
```

Extension directories commonly follow this pattern:

```text
publisher.extension-version
```

Generic examples:

```text
publisher.language-support-1.0.0
publisher.formatter-2.1.0
publisher.debugger-3.0.0-win32-x64
```

### `extensions.json`

VS Code maintains metadata about installed extensions in `extensions.json`. Depending on the extension, entries can include:

- Extension identifier
- UUID
- Version
- Local installation path
- Publisher information
- Installation timestamp
- Target platform
- Marketplace/gallery source
- Update state
- Pre-release state

> Do not publish a workstation's raw `extensions.json` without reviewing it first. It can contain local paths and other machine-specific metadata.

### `.obsolete`

The `.obsolete` file is used by VS Code during extension update/removal housekeeping. Old extension directories can temporarily remain after an update.

Avoid manually deleting hidden extension-management files while VS Code is running.

---

## List installed extensions

### Basic list

```powershell
code --list-extensions
```

Generic output:

```text
publisher.extension-one
publisher.extension-two
publisher.extension-three
```

### Include versions

```powershell
code --list-extensions --show-versions
```

Generic output:

```text
publisher.extension-one@1.0.0
publisher.extension-two@2.0.0
```

### Save the inventory

```powershell
code --list-extensions --show-versions > vscode-extensions.txt
```

Review generated inventory files before publishing them.

---

## Install and uninstall extensions

Install an extension by Marketplace ID:

```powershell
code --install-extension publisher.extension
```

Install a specific version when supported:

```powershell
code --install-extension publisher.extension@version
```

Uninstall:

```powershell
code --uninstall-extension publisher.extension
```

---

## VSIX offline installation

A VS Code extension can be packaged as a `.vsix` file and installed without using the Marketplace directly.

### Command line

```powershell
code --install-extension myextension.vsix
```

### VS Code UI

1. Open **Extensions** with `Ctrl+Shift+X`.
2. Open the Extensions view menu.
3. Select **Install from VSIX...**.
4. Select the `.vsix` file.

VSIX installation is useful for:

- Offline systems
- Internal extensions
- Testing development builds
- Controlled enterprise deployment

> Extensions installed manually from VSIX do not use normal auto-update behavior by default.

---

## Extension management in VS Code

Open Extensions:

```text
Ctrl+Shift+X
```

Useful filters include:

```text
@installed
@enabled
@disabled
@builtin
@deprecated
@recommended
@updates
@workspaceUnsupported
```

Category examples:

```text
@category:themes
@category:formatters
@category:linters
@category:snippets
```

Filters can be combined:

```text
@installed @category:themes
```

Extensions can also be:

- Enabled globally
- Disabled globally
- Enabled only for a workspace
- Disabled only for a workspace
- Updated
- Installed at another version
- Uninstalled

### Settings Sync

VS Code Settings Sync can synchronize extensions and other editor configuration between machines.

Use Settings Sync for normal multi-device extension synchronization instead of manually copying the complete extensions directory.

---

## Changing the extensions directory

For special environments, VS Code can use a custom extensions directory.

```powershell
code --extensions-dir "D:\VSCode\Extensions"
```

This is useful for:

- Portable environments
- Restricted system disks
- Testing
- Separate extension sets
- Enterprise-managed workstations

Another advanced option is using a Windows directory junction or symbolic link, but this should be treated as an advanced configuration rather than the default synchronization method.

Example concept:

```text
%USERPROFILE%\.vscode\extensions
        ↓
Directory junction / symbolic link
        ↓
D:\VSCode\Extensions
```

Back up the existing directory before changing storage configuration.

---

## Extension anatomy

The most important file in most extensions is:

```text
package.json
```

It is the extension manifest and can define information such as:

```text
Extension
├── name
├── displayName
├── publisher
├── version
├── description
├── engines.vscode
├── main / browser
├── activationEvents
└── contributes
    ├── commands
    ├── menus
    ├── views
    ├── configuration
    ├── keybindings
    ├── languages
    ├── themes
    └── debuggers
```

Example minimal manifest:

```json
{
  "name": "my-tools",
  "displayName": "My Local Tools",
  "description": "Local VS Code development tools",
  "version": "1.0.0",
  "publisher": "local",
  "engines": {
    "vscode": "^1.89.0"
  },
  "main": "./extension.js",
  "activationEvents": [
    "onCommand:myTools.showProjectInfo"
  ],
  "contributes": {
    "commands": [
      {
        "command": "myTools.showProjectInfo",
        "title": "My Tools: Show Project Info"
      }
    ]
  }
}
```

---

## Extension API capabilities

VS Code was designed to be extensible. Extensions can customize much of the editor and workbench.

| Area | API / Capability | Example |
|---|---|---|
| Commands | `vscode.commands` | Add custom commands |
| Editor | `vscode.window.activeTextEditor` | Read or change the active file |
| Workspace | `vscode.workspace` | Inspect workspace folders/configuration |
| Files | `vscode.workspace.fs` | Read/write files |
| Terminal | `vscode.window.createTerminal()` | Launch terminal workflows |
| Diagnostics | Language diagnostics APIs | Errors and warnings |
| Status bar | `createStatusBarItem()` | Show project/tool status |
| Tree views | Tree Data Provider | Custom sidebar views |
| Webviews | Webview API | HTML/CSS/JS UI |
| Notifications | Window API | Information/warning/error messages |
| User input | Quick Pick / Input Box | Interactive tools |
| Tasks | `vscode.tasks` | Build/deployment tasks |
| Debugging | Debug API | Debug adapters and workflows |
| Languages | Language APIs | Completion, hover, formatting |
| Secrets | `context.secrets` | Secure secret storage |
| Themes | Contribution points | Color and file icon themes |

Extensions can change themes and icons, add custom views and Webviews, add language/debugging support, contribute commands and menus, and provide linters, formatters, snippets, or SCM integrations.

---

## Local extension development

A very small JavaScript extension can be built without a complex build system.

```text
my-extension\
├── package.json
└── extension.js
```

Example `extension.js`:

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

            const document = editor.document;

            vscode.window.showInformationMessage(
                `File: ${document.fileName} | Language: ${document.languageId}`
            );
        }
    );

    context.subscriptions.push(command);
}

function deactivate() {}

module.exports = { activate, deactivate };
```

For larger extensions, TypeScript, tests, linting, packaging, and CI are recommended.

---

## PowerShell inventory

The reusable script in `scripts/Get-VSCodeExtensions.ps1` scans installed VS Code extensions and reads each extension's `package.json`.

Use environment variables rather than hard-coded user directories:

```powershell
$extensionsPath = Join-Path $env:USERPROFILE ".vscode\extensions"
```

Useful fields include:

```text
Name
ID
Version
Publisher
Description
VS Code engine
Entry point
Commands
Path
Product
```

Before publishing generated reports, sanitize machine-specific paths and metadata.

---

## Security and privacy

VS Code extensions should be treated as executable software.

Important practices:

- Install extensions only from publishers you trust.
- Review publisher identity and extension information before installation.
- Keep extensions updated.
- Remove extensions you no longer use.
- Be cautious with extensions that execute shell commands or external programs.
- Be cautious with extensions that access repositories, credentials, files, terminals, or remote systems.
- Use Workspace Trust when opening untrusted projects.
- Prefer Marketplace-signed packages or controlled internal distribution.

### Protect data in public repositories

Do not publish real values such as:

```text
C:\Users\<REAL_USERNAME>\...
Employee or account IDs
Computer/host names
Internal domains
Internal IP addresses
Email addresses
Access tokens, API keys, passwords, or secrets
Raw configuration files containing local metadata
```

Prefer generic or environment-variable forms:

```text
%USERPROFILE%\.vscode\extensions
$env:USERPROFILE\.vscode\extensions
C:\Users\<USERNAME>\.vscode\extensions
<HOSTNAME>
<INTERNAL_DOMAIN>
<IP_ADDRESS>
```

### Audit ideas

A local extension audit can inspect:

```text
Extension ID
Publisher
Version
Installation path
Activation events
Commands
Entry point
Executable files
Native binaries
External processes
Network-related code
Package dependencies
Install/update timestamp
Old duplicate versions
```

---

## Troubleshooting

### Multiple version directories

After an update, an old version directory may temporarily remain:

```text
publisher.extension-1.0.0
publisher.extension-1.1.0
```

Use the VS Code CLI to determine the active installed version:

```powershell
code --list-extensions --show-versions
```

Do not assume every directory under `.vscode\extensions` is currently active.

### Extension does not load

Check:

1. **View → Output**
2. Select **Log (Extension Host)** or the relevant extension output channel.
3. Run `Developer: Show Running Extensions`.
4. Run `Developer: Reload Window`.

### Inspect an installed extension

```powershell
$extension = Join-Path $env:USERPROFILE ".vscode\extensions\publisher.extension-version"
Set-Location $extension
Get-Content package.json
```

### Clean removal

Prefer:

```powershell
code --uninstall-extension publisher.extension
```

rather than deleting the extension directory manually.

---

## Repository structure

```text
VisualStudioCode/
├── README.md
├── scripts/
│   └── Get-VSCodeExtensions.ps1
└── examples/
    └── minimal-extension/
        ├── package.json
        └── extension.js
```

---

## References

Official Visual Studio Code documentation:

- Extension Marketplace: https://code.visualstudio.com/docs/configure/extensions/extension-marketplace
- Extension API: https://code.visualstudio.com/api
- Extension samples: https://github.com/microsoft/vscode-extension-samples
- Extension manifest: https://code.visualstudio.com/api/references/extension-manifest
- Contribution points: https://code.visualstudio.com/api/references/contribution-points
- VS Code API reference: https://code.visualstudio.com/api/references/vscode-api
- Extension security: https://code.visualstudio.com/docs/configure/extensions/extension-runtime-security

---

## Goal

This repository provides a practical technical reference for VS Code users, system administrators, extension developers, offline environments, enterprise extension management, troubleshooting, and auditing without exposing workstation-specific personal information.
