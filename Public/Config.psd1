@{
  # Module Cofiguration
  Credential = [System.Net.CredentialCache]::DefaultNetworkCredentials
  SPEnvironment = "2016"
  Proxy = $true
  AddCSOM = $false
  # Default Connection
  SPUrl = "http://my.cool.site"
  # Site Collection
  SiteUrl = "/projects"
  SiteTitle = ""
  SiteTemplate = ""
  SiteDescription = ""
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