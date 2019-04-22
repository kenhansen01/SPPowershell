@{
  # Module Cofiguration
  Credential = [System.Net.CredentialCache]::DefaultNetworkCredentials
  SPVersion = "2016"
  Proxy = $true
  AddCSOM = $false
  # Default Connection
  ConnectionUrl = "http://my.cool.site"
  # Site Collection
  SiteSearchUrl = "/projects"
  SiteSearchTitle = ""
  SiteSearchTemplate = ""
  SiteSearchDescription = ""
  # Site Groups / Users
  GroupTitle = "GroupTitle"
  GroupDescription = "Group for robots"
  GroupOwner = "DOMAIN\username" # O365 uses email format
  GroupUsers = @(
    "DOMAIN\username",
    "DOMAIN\username",
    "DOMAIN\username",
    "DOMAIN\username",
    "DOMAIN\username"
  ) # O365 uses email format
}