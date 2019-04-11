Function Set-PnPPowershell {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPEnvironment
  .PARAMETER SPRootUrl
  .EXAMPLE
  #>
  [cmdletbinding()]
  param(
    # Credential
    # [Parameter(ValueFromPipelineByPropertyName = $True, Position=1)]
    # [pscredential]
    # $Credential,
    # SP Environment
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory, Position=0)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # SP Root Url
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory, Position=1)]
    [string]
    $SPUrl
  )
  BEGIN
  {
    Write-Verbose "Setting webclient credentials to default in order to communicate with PowerShell Gallery"
    $webclient = New-Object System.Net.WebClient
    $webclient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
  }
  PROCESS
  {
    Write-Verbose "Finding PNP Module for SharePointPnPPowershell$SPEnvironment"
    $moduleName = "SharePointPnPPowershell$SPEnvironment"
    $module = Get-Module $moduleName
    if (!$module) {
      Write-Verbose "SharePointPnPPowershell$SPEnvironment module not found. Installing."
      Install-Module $moduleName -AllowClobber -Verbose:$VerbosePreference
    } else {
      Write-Verbose "SharePointPnPPowershell$SPEnvironment module is already installed, checking for updates."
      Update-Module $moduleName -Verbose:$VerbosePreference
    }
    Import-Module $moduleName -Verbose:$VerbosePreference

    Connect-PnPOnline -Url $SPUrl -CurrentCredentials

    # Write-Verbose "Finding CSOM Package Microsoft.SharePoint$SPEnvironment.CSOM"
    # $csomPackage = Get-Package "Microsoft.SharePoint$SPEnvironment.CSOM"
    # if (!$csomPackage) {
    #   Write-Verbose " Microsoft.SharePoint$SPEnvironment.CSOM not found. Installing."
    #   Install-Package -ProviderName NuGet -Name "Microsoft.SharePoint$SPEnvironment.CSOM" -Source https://www.nuget.org/api/v2 -Verbose:$VerbosePreference
    # } else {
    #   Write-Verbose " Microsoft.SharePoint$SPEnvironment.CSOM already installed, checking for updates."
    #   Install-Package -ProviderName NuGet -Name "Microsoft.SharePoint$SPEnvironment.CSOM" -Source https://www.nuget.org/api/v2 -InstallUpdate -Verbose:$VerbosePreference
    # }
  }
  END
  {
    Write-Verbose "PnPPowershell is ready!"
  }
}


