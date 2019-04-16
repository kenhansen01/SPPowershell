# class SPConfigure : Object {
#   # Properties
#   [String]$Title
#   [String]$Url
#   [String]$Description
#   [String]$WebTemplate
# }

class SPConfigure {
  
  [PSCustomObject]$Configuration

  SPConfigure() {
    $this.Configuration = [PSCustomObject](Import-PowerShellDataFile .\Private\Config.psd1)
  }

  SPConfigure([PSCustomObject]$config) {
    $initialConfig = [PSCustomObject](Import-PowerShellDataFile .\Private\Config.psd1)
    $tempConfig = [PSCustomObject]@{}
    foreach ($p in $initialConfig.psobject.Properties) { 
      Write-Host $p.Name
      $prop = $tempConfig."$($p.Name)"
      if ($prop) {
        $tempConfig | Set-ItemProperty -Name $p.Name -Value $p.Value -Force
      } else {
        $tempConfig | Add-Member -Name $p.Name -Type NoteProperty -Value $p.Value
      }
    }
    foreach ($p in $config.psobject.Properties) { 
      $tempConfig
      Write-Host "Name: $($p.Name)"
      Write-Host $p.Value
      $prop = $tempConfig."$($p.Name)"
      Write-Host $prop
      if ($prop) {
        Write-Verbose "Set $($p.Name)"
        $tempConfig | Set-ItemProperty -Name $p.Name -Value $p.Value -Force
      } else {
        $tempConfig | Add-Member -Name $p.Name -Type NoteProperty -Value $p.Value
      }
    }
    $this.Configuration = $tempConfig
    Write-Host $this.Configuration.SiteUrl
  }
  
  # [SPSelectSite[]] Sites () {
  #   return $this.AllSites
  # }

  # [SPSelectSite[]] SitesByUrl ([String]$UrlFragment) {
  #   return $this.AllSites | Where-Object { $_.Url -like "*$UrlFragment*"}
  # }

  # [SPSelectSite[]] SitesByTitle ([String]$TitleFragment) {
  #   return $this.AllSites | Where-Object { $_.Title -like "*$TitleFragment*"}
  # }

  # [SPSelectSite[]] SitesByTemplate ([String]$Template) {
  #   return $this.AllSites | Where-Object { $_.WebTemplate -like "*$Template*"}
  # }

  # [SPSelectSite[]] SitesByDescription ([String]$DescriptionFragment) {
  #   return $this.AllSites | Where-Object { $_.Description -like "*$DescriptionFragment*"}
  # }
}
