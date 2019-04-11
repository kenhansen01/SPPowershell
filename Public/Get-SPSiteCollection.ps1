
Function Get-SPSiteCollection {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER ComputerNames
  .PARAMETER SPSiteUrlPattern
  .PARAMETER RunConcurrent
  .PARAMETER ScriptBlock
  .EXAMPLE
  #>
  [cmdletbinding()]
  param(
    # Credential
    # [Parameter(ValueFromPipelineByPropertyName = $True)]
    # [pscredential]
    # $Credential,
    # SP Environment
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory, Position=0)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory, Position=1)]
    [string]
    $SPUrl,
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
    
    
  }
  PROCESS
  {
    if(!(Get-PnPConnection)){
      Set-PnPPowershell -SPEnvironment $SPEnvironment -SPUrl $SPUrl -Verbose:$VerbosePreference
    }    
    $SelectSites = [SPSelectSites]::new()
    
    if ($AllSites) { $SiteCollections = $SelectSites.AllSites }
    if ($ByUrl) { $SiteCollections = $SelectSites.SitesByUrl($SiteUrl) }
    if ($ByTitle) { $SiteCollections = $SelectSites.SitesByTitle($SiteTitle) } 
    if ($ByTemplate) { $SiteCollections = $SelectSites.SitesByTemplate($SiteTemplate) }
    if ($ByDescription) { $SiteCollections = $SelectSites.SitesByDescription($SiteDescription) }
    $SiteCollections
  }
  END
  {
    
  }
}