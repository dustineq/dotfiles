<#
    .Synopsis
        Configure RipGrep (rg) for this Dotfiles configuration
    .Description
        Bootstraps the rg portion of the Dotfiles repository
    .Notes
        ./RipGrep/ripgreprc is Symlinked to $HOME/.ripgreprc.

        Environment varibable RIPGREP_CONFIG_PATH is set to $HOME/.ripgreprc
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
Process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    $ripgreprcPath = (Join-Path -Path $HOME -ChildPath '.ripgreprc')

    New-SymbolicLink `
        -Path $ripgreprcPath `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'ripgreprc') `
        -whatif:$optWhatIf

    Set-UserEnvVar -Name RIPGREP_CONFIG_PATH -Value $ripgreprcPath
}
