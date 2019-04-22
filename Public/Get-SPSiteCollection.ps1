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
  .PARAMETER SPVersion
  .PARAMETER ConnectionUrl
  .PARAMETER CustomConfig
  .PARAMETER AllSites
  .PARAMETER ByUrl
  .PARAMETER ByTitle
  .PARAMETER ByTemplate
  .PARAMETER ByDescription
  .PARAMETER SiteSearchUrl
  .PARAMETER SiteSearchTitle
  .PARAMETER SiteSearchTemplate
  .PARAMETER SiteSearchDescription
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
    $SPVersion,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $ConnectionUrl,
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
    $SiteSearchUrl,
    # title string fragment to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByTitle')]
    [string]
    $SiteSearchTitle,
    # template string to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByTemplate')]
    [string]
    $SiteSearchTemplate,
    # description string to search sites by
    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName='ByDescription')]
    [string]
    $SiteSearchDescription
  )
  BEGIN
  {
    $customConfigObject = [PSCustomObject]@{
      Credential = $Credential
      SPVersion = $SPVersion
      ConnectionUrl = $ConnectionUrl
      SiteSearchUrl = $SiteSearchUrl
      SiteSearchTitle = $SiteSearchTitle
      SiteSearchTemplate = $SiteSearchTemplate
      SiteSearchDescription = $SiteSearchDescription
    }
    if(!$config -or !!$ConfigFile -or $CustomConfig) {
      Set-SPModuleConfiguration -CustomConfig:$CustomConfig -CustomConfigObject $customConfigObject -ConfigFile $ConfigFile
    }
    if ($config.Credential) {
      Connect-PnPOnline -Url $config.ConnectionUrl -Credentials $Credential
    } else {
      Write-Verbose "Connecting to $($config.ConnectionUrl)"
      Connect-PnPOnline -Url $config.ConnectionUrl -CurrentCredentials
    }
  }
  PROCESS
  {
    $SelectSites = [SPSelectSites]::new()
    
    if ($AllSites) { $SiteCollections = $SelectSites.AllSites }
    if ($ByUrl) { $SiteCollections = $SelectSites.SitesByUrl($config.SiteSearchUrl) }
    if ($ByTitle) { $SiteCollections = $SelectSites.SitesByTitle($config.SiteSearchTitle) } 
    if ($ByTemplate) { $SiteCollections = $SelectSites.SitesByTemplate($config.SiteSearchTemplate) }
    if ($ByDescription) { $SiteCollections = $SelectSites.SitesByDescription($config.SiteSearchDescription) }
    $SiteCollections
  }
  END
  {
    Disconnect-PnPOnline
  }
}