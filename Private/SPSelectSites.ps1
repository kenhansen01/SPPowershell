class SPSelectSite : Object {
  # Properties
  [String]$Title
  [String]$Url
  [String]$Description
  [String]$WebTemplate
}

class SPSelectSites {
  [SPSelectSite[]]$AllSites

  SPSelectSites() {
    $this.AllSites = Get-PnpSiteSearchQueryResults |
      ForEach-Object {[SPSelectSite]@{
        Title = $_.Title;
        Url = $_.Url;
        Description = $_.Description;
        WebTemplate = $_.WebTemplate;
      }}
  }
  
  [SPSelectSite[]] Sites () {
    Write-Verbose "Finding all sites."
    return $this.AllSites
  }

  [SPSelectSite[]] SitesByUrl ([String]$UrlFragment) {
    Write-Verbose "Finding sites where url matches: *$UrlFragment*"
    return $this.AllSites | Where-Object { $_.Url -like "*$UrlFragment*"}
  }

  [SPSelectSite[]] SitesByTitle ([String]$TitleFragment) {
    return $this.AllSites | Where-Object { $_.Title -like "*$TitleFragment*"}
  }

  [SPSelectSite[]] SitesByTemplate ([String]$Template) {
    return $this.AllSites | Where-Object { $_.WebTemplate -like "*$Template*"}
  }

  [SPSelectSite[]] SitesByDescription ([String]$DescriptionFragment) {
    return $this.AllSites | Where-Object { $_.Description -like "*$DescriptionFragment*"}
  }
}
