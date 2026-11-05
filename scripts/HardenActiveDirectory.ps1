<#
.SYNOPSIS
    Harden-ActiveDirectory.ps1 - Lean zero-dependency AD unconstrained delegation auditor & remediator.
.EXAMPLE
    .\HardenActiveDirectory.ps1
    .\HardenActiveDirectory.ps1 -Remediate -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$DomainController,
    [switch]$Remediate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$searcher = [adsisearcher]"(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))"
if ($DomainController) { 
    $searcher.SearchRoot = [adsi]"LDAP://$DomainController/RootDSE" 
}

$computers = $searcher.FindAll()
if (-not $computers) {
    Write-Output "[+] PASS: No computer accounts found with Unconstrained Delegation."
    return
}

Write-Warning "Found $($computers.Count) computer(s) with Unconstrained Delegation."

foreach ($comp in $computers) {
    $name = $comp.Properties.name
    $dn   = $comp.Properties.distinguishedname

    if ($Remediate) {
        if ($PSCmdlet.ShouldProcess($name, "Remove TRUSTED_FOR_DELEGATION flag")) {
            $entry = [adsi]"LDAP://$dn"
            $entry.userAccountControl = ([int]$entry.userAccountControl.Value -bxor 524288)
            $entry.SetInfo()
            Write-Output "[+] Successfully remediated: $name"
        }
    } else {
        Write-Output "[-] Found: $name ($dn)"
    }
}