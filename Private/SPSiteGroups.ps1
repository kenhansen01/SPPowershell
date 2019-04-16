class SPSiteGroup : Object {
  [Int32]$Id
  [String]$Title
  [String]$LoginName
  [String]$OwnerTitle
}

class AtlasSiteGroups {
  [SPSiteGroup[]]$AllGroups
  [SPSiteGroup]$SelectedGroup

  AtlasSiteGroups() {
    $this.AllGroups = Get-PnPGroup |
      ForEach-Object {[SPSiteGroup]@{
        Id = $_.Id;
        Title = $_.Title;
        LoginName = $_.LoginName;
        OwnerTitle = $_.OwnerTitle;
      }}
  }

  [SPSiteGroup[]] Groups () {
    return $this.AllGroups
  }

  [SPSiteGroup] GroupById ([Int32]$Id) {
    return $this.AllGroups | Where-Object ($_.Id -eq $Id)
  }

  [SPSiteGroup] GroupByTitle ([String]$Title) {
    return $this.AllGroups | Where-Object ($_.Title -eq $Title)
  }
  
  [SPSiteGroup[]] GroupByLogin ([String]$LoginName) {
    return $this.AllGroups | Where-Object ($_.LoginName -eq $LoginName)
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