function Add-WindowsDefenderExclude {
	<#
	.SYNOPSIS
	Sets WindowsDefender to work with PSILoveBackups
	#>
	[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Get-MpPreference")]
	[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Add-MpPreference")]
	[CmdletBinding()]
	param($Command)

	if (-not $IsWindows) { return }

	Import-Module -Name ConfigDefender -ErrorAction SilentlyContinue
	if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		Write-Warning 'WindowsDefender ExclusionProcesses requires administrator privileges to set. Skipping.'
		return
	}

	$ep = Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess
	$rp = (Get-Command $Command).Path
	if ((Test-Path $rp) -and ($ep -notcontains $rp)) {
		$ep += $rp

		Write-Verbose "Adding exlucsion $rp to WindowsDefender exclusions: $ep"
		Add-MpPreference -ExclusionProcess $ep
	}
}

$ModuleRepository = 'PSGallery'
$ModuleScope = 'CurrentUser'

Set-PSRepository -Name $ModuleRepository -InstallationPolicy 'Trusted'

$modulesToManage = @('posh-git', 'PSFzf', 'PSScriptAnalyzer', 'PSReadLine', 'Terminal-Icons', 'PowerShellForGitHub')
if ($IsLinux -or $IsMacOS) {
	$modulesToManage += 'Microsoft.PowerShell.UnixCompleters' # PSUnixUtilCompleters
}

$modulesToManage | Where-Object {
	$null -eq (Get-Module -Name $PSItem -ListAvailable -ErrorAction 'Continue')
} | ForEach-Object {
	Install-Module -Name $PSItem -Repository $ModuleRepository -Scope $ModuleScope
}