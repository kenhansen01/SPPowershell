Function Get-SPSiteCollection {
  <#
  .SYNOPSIS
    Get site collections using search feature.
  .DESCRIPTION
    Gets desired site collections. Various partial filters can be applied to return the desired set.
  .PARAMETER ConfigFile
    Location of  custom config file. 

    EX: "C:\Users\ME\Documents\Powershell\config.psd1"
  .PARAMETER Credential
    Credentials to connect to SharePoint. Default is current logged in user.
  .PARAMETER SPEnvironment
  .PARAMETER SPUrl
  .PARAMETER CustomConfig
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
    # config file custom location
    [Parameter(ValueFromPipelineByPropertyName = $True, ValueFromPipeline, Position=0)]
    [string]
    $ConfigFile,
    # Credential
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [pscredential]
    $Credential,
    # SP Environment
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $SPUrl,
    # Custom Config
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
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByUrl')]
    [string]
    $SiteUrl,
    # title string fragment to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByTitle')]
    [string]
    $SiteTitle,
    # template string to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByTemplate')]
    [string]
    $SiteTemplate,
    # description string to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByDescription')]
    [string]
    $SiteDescription
  )
  BEGIN
  {
    $customConfigObject = [PSCustomObject]@{
      Credential = $Credential
      SPEnvironment = $SPEnvironment
      SPUrl = $SPUrl
      SiteUrl = $SiteUrl
      SiteTitle = $SiteTitle
      SiteTemplate = $SiteTemplate
      SiteDescription = $SiteDescription
    }
    if(!$config -or !!$ConfigFile -or $CustomConfig) {
      Set-SPModuleConfiguration -CustomConfig:$CustomConfig -CustomConfigObject $customConfigObject -ConfigFile $ConfigFile
    }
    if ($config.Credential) {
      Connect-PnPOnline -Url $config.SPUrl -Credentials $Credential
    } else {
      Write-Verbose "Connecting to $($config.SPUrl)"
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