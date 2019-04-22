Function Get-SPSiteGroup {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPVersion
  .PARAMETER ConnectionUrl
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
    $customConfigObject = [PSCustomObject]@{
      Credential = $Credential
      SPVersion = $SPVersion
      ConnectionUrl = $ConnectionUrl
      GroupId = $GroupId
      GroupTitle = $GroupTitle
      GroupLoginName = $GroupLoginName
      GroupOwnerTitle = $GroupOwnerTitle
    }
    if(!$config -or !!$ConfigFile -or $CustomConfig) {
      Set-SPModuleConfiguration -CustomConfig:$CustomConfig -CustomConfigObject $customConfigObject -ConfigFile $ConfigFile
    }
    Write-Verbose "Group Title: $($config.GroupTitle)"
    if ($config.Credential) {
      Connect-PnPOnline -Url $config.ConnectionUrl -Credentials $Credential
    } else {
      Write-Verbose "Connecting to $($config.ConnectionUrl)"
      Connect-PnPOnline -Url $config.ConnectionUrl -CurrentCredentials
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