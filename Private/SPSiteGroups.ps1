class SPSiteGroup : Object {
  [Int32]$Id
  [String]$Title
  [String]$LoginName
  [String]$OwnerTitle
}

class SPSiteGroups {
  [SPSiteGroup[]]$AllGroups
  [SPSiteGroup[]]$SelectedGroup

  SPSiteGroups() {
    $this.AllGroups = Get-PnPGroup |
      ForEach-Object {[SPSiteGroup]@{
        Id = $_.Id;
        Title = $_.Title;
        LoginName = $_.LoginName;
        OwnerTitle = $_.OwnerTitle;
      }}
  }

  [SPSiteGroup[]] Groups () {
    Write-Verbose "All Groups"
    return $this.AllGroups
  }

  [SPSiteGroup[]] GroupById ([Int32]$Id) {
    Write-Verbose "Group ID: $Id"
    return $this.AllGroups | Where-Object {$_.Id -eq $Id}
  }

  [SPSiteGroup[]] GroupByTitle ([String]$Title) {
    Write-Verbose "Group Title: $Title"
    return $this.AllGroups | Where-Object {$_.Title -eq $Title}
  }
  
  [SPSiteGroup[]] GroupByLogin ([String]$LoginName) {
    Write-Verbose "Group LoginName: $LoginName"
    return $this.AllGroups | Where-Object {$_.LoginName -eq $LoginName}
  }

  [SPSiteGroup] NewSiteGroup (
    [String]$Title,
    [String]$Description,
    [String]$Owner
  ) {
    return (New-PnPGroup -Title $Title -Description $Description -Owner $Owner) | ForEach-Object {[SPSiteGroup]@{
      Id = $_.Id;
      Title = $_.Title;
      LoginName = $_.LoginName;
      OwnerTitle = $_.OwnerTitle;
    }}
  }

  [void] AddRole (
    [String]$GroupName,
    [String]$Role
  ) {
    Set-PnPGroup -Identity $GroupName -AddRole $Role
  }

  [void] NewGroupMember (
    [String]$GroupName,
    [String[]]$LoginName
  ) {
    $LoginName | ForEach-Object { Add-PnPUserToGroup -LoginName $_ -Identity $GroupName }
  }
}