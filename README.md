# SSH Protocol Handler for Windows Terminal

## Description
An SSH Protocol Handler Powershell Script for opening SSH connections in Windows Terminal.

When set as the protcol handler for SSH it can open links passed by your browser.

Use at your own risk. I haven't extensively tested this and I do not profess to be fluent in Powershell Scripting. Fixes and cleanup are welcome.

### Features:
* Parses passed SSH links such as `ssh://someone@someserverip:22` and attempts to santize the input
* Verifies the required applications are installed
* Allows you to choose between OpenSSH and plink (Putty) SSH Clients
* Constructs the arguments required by Windows Terminal and the SSH Client

## Installation

### One-line Install (Recommended)

Run the following command in PowerShell to automatically download the handler script and configure all required registry keys for the current user:

```powershell
irm https://raw.githubusercontent.com/raymondclowe/windows-terminal-ssh-protocol-handler/main/install.ps1 | iex
```

> **Security note:** As with any `irm ... | iex` install command, you are trusting the content served over HTTPS from this repository. You can review the [`install.ps1`](install.ps1) script before running it.

The installer will:
1. Download `windows-terminal-ssh-protocol-handler.ps1` to `~\Documents\PowerShell\Scripts\`
2. Create all required registry entries so `ssh://` links open in Windows Terminal
3. Register the application so Windows recognises the protocol handler

#### Custom Install Path

To install the handler script to a different directory, save `install.ps1` locally and run it with the `-InstallPath` parameter:

```powershell
.\install.ps1 -InstallPath "C:\Scripts"
```

### Manual Installation

Alternatively, copy `windows-terminal-ssh-protocol-handler.ps1` to a location of your choosing, edit `add-ssh-handler.reg` to replace `<User>` with your Windows username, and then double-click the `.reg` file to import the registry entries.

## Requirements
* **Windows Terminal**
  - Store Link: https://www.microsoft.com/en-us/p/windows-terminal-preview/9n0dx20hk701
* **SSH Client**
  - Option 1: OpenSSH Client - Windows Feature from Windows 10 1809 on
    - How-to Enable: https://bit.ly/2HIcRDm
  - Option 2: plink SSH Client (Putty)
    - Download Link: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
    - Note: plink.exe path must be defined in your PATH environment variable
* **Registry Entries** - to set the script as the handler for `URL:Protocol SSH`

## Usage
Basic usage of the script involves calling it via powershell. The first argument should be the URL to parse.

```powershell .\windows-terminal-ssh-protocol-handler.ps1 ssh://<username>@<ipAddress|hostname>:<port>```

`URL:Protocol SSH` can be set in the Windows Registry to point to this script via the included `add-ssh-handler.reg`. You MUST change the `<user>` value in the reg file before importing it. As with andything that adds to the registry, be cautious when editing and importing.

```powershell "C:\Users\<user>\Documents\PowerShell\Scripts\windows-terminal-ssh-protocol-handler.ps1" %1```

#### Script Options:
The script can be customized by modifying the options listed at the top of the script file.

* `$sshPreferredClient` : Set the SSH Client you would like Windows Terminal to call
  - Default: `'openssh'`
  - Supported Options: `'openssh, plink'`
* `$sshVerbosity` : Set if you would like the SSH Client to show more information
  - Default: `$false`
  - Supported Options: `$true, $false`
* `$sshConnectionTimeout` : Set the time OpenSSH will wait for connection in seconds before timing out
  - Default: `<emtpyString>` - We will let OpenSSH decide based on the system TCP timeout
  - Supported Options: `<integer>`
  - Note: Only applies to OpenSSH
* `$wtProfile` : Set the profile Windows Terminal will use
  - Default: `<emtpyString>` We will let Windows Terminal decide based on its defaults
  - Supported Options: `<windowsTerminalProfileName>`
