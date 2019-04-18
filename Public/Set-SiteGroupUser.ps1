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
    [Parameter(ValueFromPipelineByPropertyName = $True, Position=0)]
    [ValidateSet("2013","2016","2019","Online")]
    [string]
    $SPEnvironment,
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True, Position=1)]
    [string]
    $SPUrl,
    # config file custom location
    [Parameter(ValueFromPipelineByPropertyName = $True, Position=1)]
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
      SPUrl = $SPUrl
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
  }
  END
  {
    Disconnect-PnPOnline
  }
}