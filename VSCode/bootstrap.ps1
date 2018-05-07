<#
    .Synopsis
        Configure VSCode and necessary modules for Dotfiles

    .Description
        Bootstraps the VSCode portion of the Dotfiles Repository

    .Parameter Uninstall
        Removes appropriate installed files outside of the Dotfiles repository.

    .Parameter Confirm
        Approves all prompts

    .Example
        # Run bootstrapper, approving everything
        .\bootstrap.ps1 -Confirm

    .Example
        # Uninstall
        .\bootstrap.ps1 -Uninstall

    .Notes
        Check symlink map for additional information

#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [switch]$confirm,
    [switch]$uninstall
)
Begin
{
    $dotfilesModulePath = Resolve-Path (Join-Path $PSScriptRoot ../WindowsPowerShell/Modules-Dotfiles/Dotfiles/Dotfiles.psm1)
    Import-Module -Name $dotfilesModulePath
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
}
Process
{
    # Maps: AppData/Roaming/Code/User/* -> $dotfiles/VSCode/*
    $symlinks = @{
        (Join-Path "$env:APPDATA\Code\User\" "settings.json") = (Join-Path $PSScriptRoot settings.json);
        (Join-Path "$env:APPDATA\Code\User\" "keybindings.json") = (Join-Path $PSScriptRoot keybindings.json);
        (Join-Path "$env:APPDATA\Code\User\" "snippets") = (Join-Path $PSScriptRoot snippets\);
    }

    $vscodeExtensions = @(
        'EditorConfig.EditorConfig',
        'ms-vscode.csharp',
        'ms-vscode.PowerShell',
        'ms-vsts.team',
        'PeterJausovec.vscode-docker',
        'robertohuertasm.vscode-icons'
        'vscodevim.vim'
    )

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] }

        $vscodeExtensions | Foreach-Object {
            Write-Verbose "having VSCode install $_"
            code --install-extension $_
        }
    }
}
