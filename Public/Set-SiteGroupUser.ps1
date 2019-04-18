Function Set-SiteGroupUser {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPEnvironment
  .PARAMETER SPUrl
  .PARAMETER GroupTitle
  .PARAMETER GroupUsers
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
    [Parameter(ValueFromPipelineByPropertyName = $True, ValueFromPipeline, Position=0)]
    [string]
    $SPUrl,
    # Custom Config
    [Parameter()]
    [switch]
    $CustomConfig,
    # config file custom location
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $ConfigFile,
    # title string fragment to search groups by
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $GroupTitle,
    # group role to set, default Contribute
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $GroupRole = "Contribute",
    # title string fragment to search groups by
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string[]]
    $GroupUsers
  )
  BEGIN
  {
    $customConfigObject = [PSCustomObject]@{
      Credential = $Credential
      SPEnvironment = $SPEnvironment
      GroupTitle = $GroupTitle
      GroupUsers = $GroupUsers
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
    if($SPUrl){
      if ($config.Credential) {
        Connect-PnPOnline -Url $config.SPUrl -Credentials $config.Credential
      } else {
        Write-Verbose "Connecting to $($SPUrl)"
        Connect-PnPOnline -Url $SPUrl -CurrentCredentials
      }
    }
    $SelectGroups = [SPSiteGroups]::new()
    Write-Verbose $SelectGroups
    $GroupToSet = $SelectGroups.GroupByTitle($config.GroupTitle)
    if (!$GroupToSet) {
      Write-Verbose "Group does not exist, adding group."
      $GroupToSet = $SelectGroups.NewSiteGroup($config.GroupTitle, $config.GroupDescription, $config.GroupOwner)
    }
    Write-Verbose "Making sure $($GroupToSet.Title) is set to $GroupRole"
    $SelectGroups.AddRole($config.GroupTitle, $GroupRole)
    Write-Verbose "Making sure the members exist in $($GroupToSet.Title)"
    $SelectGroups.NewGroupMember($config.GroupTitle, $config.GroupUsers)
    if ($SPUrl) {
      Disconnect-PnPOnline
    }
  }
  END
  {
    Disconnect-PnPOnline -ErrorAction SilentlyContinue
  }
}