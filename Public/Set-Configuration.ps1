Function Set-Configuration {
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
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $SPUrl,
    # default config
    [Parameter(ParameterSetName='DefaultConfig')]
    [boolean]
    $DefaultConfig = $True,
    # all sites
    [Parameter()]
    [switch]
    $AllSites,
    # select by url
    [Parameter()]
    [switch]
    $ByUrl,
    # select by title
    [Parameter()]
    [switch]
    $ByTitle,
    # select by template
    [Parameter()]
    [switch]
    $ByTemplate,
    # select by description
    [Parameter()]
    [switch]
    $ByDescription,
    # url string fragment to search sites by
    [Parameter()]
    [string]
    $SiteUrl,
    # title string fragment to search sites by
    [Parameter()]
    [string]
    $SiteTitle,
    # template string to search sites by
    [Parameter()]
    [string]
    $SiteTemplate,
    # description string to search sites by
    [Parameter()]
    [string]
    $SiteDescription
  )
  BEGIN {}
  PROCESS
  {
    if ($DefaultConfig) {
      $config = [PSCustomObject](Import-PowerShellDataFile .\Private\Config.psd1)
      $config
    } else {
      $config = [PSCustomObject]@{
        # PnPPowershell = @{
        #   SPEnvironment = $SPEnvironment
        #   Proxy = $true
        #   AddCSOM = $false
        # }
        SPEnvironment = "2016"
        Proxy = $true
        AddCSOM = $false        
        SPUrl = $SPUrl
        AllSites = $AllSites
        SiteUrl = $SiteUrl
        SiteTitle = $SiteTitle
        SiteTemplate = $SiteTemplate
        SiteDescription = $SiteDescription
      }
    }
  }
  END {}
}