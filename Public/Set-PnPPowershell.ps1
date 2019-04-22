Function Set-PnPPowershell {
  <#
  .SYNOPSIS
    Load appropriate PnPPowershell, and optionally CSOM to use.
  
  .DESCRIPTION
    Determines whether the necessary modules / packages exist. Installs them if not, attempts to update if they do exist.

  .PARAMETER SPVersion
    Select the version of SharePoint you want to work with.
    Options:
      2013
      2016
      2019
      Online
    
    Default: Online

  .PARAMETER Proxy
    True if you are behind a Corporate Proxy. Default is true since so many SharePoint environments are set up that way.

  .PARAMETER AddCSOM
    If you need to work with CSOM directly, this switch will add/update the package.

  .EXAMPLE
    Set-PnPPowershell -SPVersion 2019

    # Set Proxy Credentials to Default (logged in user)
    # Check for SharePointPnPPowershell2019. Install or Update Module.

  .EXAMPLE
    Set-PnPPowershell -SPVersion 2013 -NoProxy -AddCSOM

    # Does not set proxy credentials.
    # Check for SharePointPnPPowershell2013. Install or Update Module.
    # Check for Microsoft.SharePoint2013.CSOM. Install or Update
    
  #>
  [cmdletbinding()]
  param(
    # SP Environment
    [Parameter(ValueFromPipelineByPropertyName)]
    # [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPVersion = "Online",
    # Behind a proxy
    [Parameter(ValueFromPipelineByPropertyName)]
    [boolean]
    $Proxy = $true,
    # Load CSOM
    [Parameter(ValueFromPipelineByPropertyName)]
    [boolean]
    $AddCSOM = $false
  )
  BEGIN
  {
    # If behind corporate proxy set proxy credentials to default.
    if ($Proxy) {
      Write-Verbose "Setting webclient credentials to default in order to communicate with PowerShell Gallery"
      $webclient = New-Object System.Net.WebClient
      $webclient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    }
  }
  PROCESS
  {
    $moduleName = "SharePointPnPPowershell$SPVersion"
    Write-Verbose "Finding PNP Module for $moduleName"

    if (!(Get-Module $moduleName -ListAvailable)) {
      Write-Verbose "SharePointPnPPowershell$SPVersion module not found. Installing."
      Install-Module $moduleName -AllowClobber -Verbose:$VerbosePreference
    } else {
      Write-Verbose "SharePointPnPPowershell$SPVersion module is already installed, checking for updates."
      Update-Module $moduleName -Verbose:$VerbosePreference
    }
    Import-Module $moduleName -Verbose:$VerbosePreference

    if ($AddCSOM) {
      Write-Verbose "Finding CSOM Package Microsoft.SharePoint$SPVersion.CSOM"
      if (!(Get-Package "Microsoft.SharePoint$SPVersion.CSOM")) {
        Write-Verbose " Microsoft.SharePoint$SPVersion.CSOM not found. Installing."
        Install-Package -ProviderName NuGet -Name "Microsoft.SharePoint$SPVersion.CSOM" -Source https://www.nuget.org/api/v2 -Verbose:$VerbosePreference
      } else {
        Write-Verbose " Microsoft.SharePoint$SPVersion.CSOM already installed, checking for updates."
        Install-Package -ProviderName NuGet -Name "Microsoft.SharePoint$SPVersion.CSOM" -Source https://www.nuget.org/api/v2 -InstallUpdate -Verbose:$VerbosePreference
      }
    }
  }
  END
  {
    Write-Verbose "PnPPowershell is ready!"
  }
}
