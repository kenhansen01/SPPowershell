Function Get-SPSiteGroup {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPEnvironment
  .PARAMETER SPUrl
  .PARAMETER DefaultConfig
  .PARAMETER AllGroups
  .PARAMETER ById
  .PARAMETER ByTitle
  .PARAMETER ByLoginName
  .PARAMETER ByOwnerTitle
  .PARAMETER GroupId
  .PARAMETER GroupTitle
  .PARAMETER GroupLoginName
  .PARAMETER GroupOwnerTitle
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
    # Custom Config
    [Parameter()]
    [switch]
    $CustomConfig,
    # all groups
    [Parameter(ParameterSetName='AllSites')]
    [switch]
    $AllGroups,
    # select by id
    [Parameter(ParameterSetName='ById')]
    [switch]
    $ById,
    # select by title
    [Parameter(ParameterSetName='ByTitle')]
    [switch]
    $ByTitle,
    # select by loginname
    [Parameter(ParameterSetName='ByLoginName')]
    [switch]
    $ByLoginName,
    # select by ownertitle
    [Parameter(ParameterSetName='ByOwnerTitle')]
    [switch]
    $ByOwnerTitle,
    # id to search groups by
    [Parameter(ParameterSetName='ById')]
    [string]
    $GroupId,
    # title string fragment to search groups by
    [Parameter(ParameterSetName='ByTitle')]
    [string]
    $GroupTitle,
    # loginname string to search groups by
    [Parameter(ParameterSetName='ByLoginName')]
    [string]
    $GroupLoginName,
    # ownertitle string to search groups by
    [Parameter(ParameterSetName='ByOwnerTitle')]
    [string]
    $GroupOwnerTitle
  )
  BEGIN
  {
    if (!$CustomConfig) {
     $config = ([SPConfigure]::new()).Configuration
    } else {      
      Write-Verbose $GroupTitle
      $config = ([SPConfigure]::new([pscustomobject]@{
        Credential = $Credential
        SPEnvironment = $SPEnvironment
        SPUrl = $SPUrl
        GroupId = $GroupId
        GroupTitle = $GroupTitle
        GroupLoginName = $GroupLoginName
        GroupOwnerTitle = $GroupOwnerTitle
      })).Configuration
    }
    Write-Verbose "$($config.GroupTitle)"
    if (!(Get-Module "SharePointPnPPowerShell$($config.SPEnvironment)")) {
      $config | Set-PnPPowershell -Verbose:$VerbosePreference
    }

    if ($config.Credential) {
      Connect-PnPOnline -Url $config.SPUrl -Credentials $Credential -Verbose:$VerbosePreference
    } else {
      Connect-PnPOnline -Url $config.SPUrl -CurrentCredentials -Verbose:$VerbosePreference
    }     
  }
  PROCESS
  {
    $SelectGroups = [SPSiteGroups]::new()
    Write-Verbose $SelectGroups

    if ($AllGroups) { $SiteGroups = $SelectGroups.AllGroups }
    if ($ById) { $SiteGroups = $SelectGroups.GroupById($config.GroupId) }
    if ($ByTitle) { $SiteGroups = $SelectGroups.GroupByTitle($config.GroupTitle) } 
    if ($ByLoginName) { $SiteGroups = $SelectGroups.GroupByLoginName($config.GroupLoginName) }
    if ($ByOwnerTitle) { $SiteGroups = $SelectGroups.GroupByOwnerTitle($config.GroupOwnerTitle) }
    $SiteGroups
  }
  END
  {
    Disconnect-PnPOnline
  }
}