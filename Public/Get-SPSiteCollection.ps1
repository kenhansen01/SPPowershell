Function Get-SPSiteCollection {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPEnvironment
  .PARAMETER SPUrl
  .PARAMETER DefaultConfig
  .PARAMETER AllSites
  .PARAMETER ByUrl
  .PARAMETER ByTitle
  .PARAMETER ByTemplate
  .PARAMETER ByDescription
  .PARAMETER SiteUrl
  .PARAMETER SiteTitle
  .PARAMETER SiteTemplate
  .PARAMETER SiteDescription
  .EXAMPLE
  #>
  [cmdletbinding()]
  param(
    # Credential
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [pscredential]
    $Credential,
    # SP Environment
    [Parameter(ValueFromPipelineByPropertyName = $True, Position=0)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True, Position=1)]
    [string]
    $SPUrl,
    # all sites
    [Parameter()]
    [switch]
    $CustomConfig,
    # all sites
    [Parameter(ParameterSetName='AllSites')]
    [switch]
    $AllSites,
    # select by url
    [Parameter(ParameterSetName='ByUrl')]
    [switch]
    $ByUrl,
    # select by title
    [Parameter(ParameterSetName='ByTitle')]
    [switch]
    $ByTitle,
    # select by template
    [Parameter(ParameterSetName='ByTemplate')]
    [switch]
    $ByTemplate,
    # select by description
    [Parameter(ParameterSetName='ByDescription')]
    [switch]
    $ByDescription,
    # url string fragment to search sites by
    [Parameter(ParameterSetName='ByUrl')]
    [string]
    $SiteUrl,
    # title string fragment to search sites by
    [Parameter(ParameterSetName='ByTitle')]
    [string]
    $SiteTitle,
    # template string to search sites by
    [Parameter(ParameterSetName='ByTemplate')]
    [string]
    $SiteTemplate,
    # description string to search sites by
    [Parameter(ParameterSetName='ByDescription')]
    [string]
    $SiteDescription
  )
  BEGIN
  {
    if (!$CustomConfig) {
     $config = ([SPConfigure]::new()).Configuration
    } else {      
      Write-Verbose $SiteUrl
      $config = ([SPConfigure]::new([pscustomobject]@{
        SPEnvironment = $SPEnvironment
        SPUrl = $SPUrl
        SiteUrl = $SiteUrl
        SiteTitle = $SiteTitle
        SiteTemplate = $SiteTemplate
        SiteDescription = $SiteDescription
      })).Configuration
    }
    write-verbose "$($config.Configuration.SiteUrl)"
    # if (!(Get-Module "SharePointPnPPowerShell$SPEnvironment")) {
      # Set-PnPPowershell -SPEnvironment $SPEnvironment -Verbose:$VerbosePreference
      $config = ([SPConfigure]::new()).Configuration
      $config | Set-PnPPowershell
    # }

    if ($Credential) {
      Connect-PnPOnline -Url $config.SPUrl -Credentials $Credential
    } else {
      Connect-PnPOnline -Url $config.SPUrl -CurrentCredentials
    }     
  }
  PROCESS
  {
    $SelectSites = [SPSelectSites]::new()
    
    if ($AllSites) { $SiteCollections = $SelectSites.AllSites }
    if ($ByUrl) { $SiteCollections = $SelectSites.SitesByUrl($config.SiteUrl) }
    if ($ByTitle) { $SiteCollections = $SelectSites.SitesByTitle($config.SiteTitle) } 
    if ($ByTemplate) { $SiteCollections = $SelectSites.SitesByTemplate($config.SiteTemplate) }
    if ($ByDescription) { $SiteCollections = $SelectSites.SitesByDescription($config.SiteDescription) }
    $SiteCollections
  }
  END
  {
    Disconnect-PnPOnline
  }
}