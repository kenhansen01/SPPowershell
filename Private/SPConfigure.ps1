class SPConfigure {
  # Configuration object returned by the class
  [PSCustomObject]$Configuration

  # Default configuration using config file uses default location unless custom is specified
  SPConfigure([string]$configFile = ".\Public\Config.psd1") {
    Write-Verbose "Setting configuration from Config.psd1"
    $this.Configuration = [PSCustomObject](Import-PowerShellDataFile $configFile)
    Write-Verbose "Configuration Complete!"
  }

    # Custom configuration, loads default config, overrides default with custom values wherever they are listed, adds property if it doesn't exist.
  SPConfigure([PSCustomObject]$config, [string]$configFile = ".\Public\Config.psd1") {
    $initialConfig = [PSCustomObject](Import-PowerShellDataFile $configFile)
    $tempConfig = [PSCustomObject]@{}
    Write-Verbose "Setting default configuration."
    foreach ($p in $initialConfig.psobject.Properties) { 
      Write-Verbose "Property: $($p.Name); Value: $($p.Value)"
      if ($p.Value) {
        Write-Verbose "Setting $($p.Name) to $($p.Value)"
        $tempConfig | Add-Member -Name $p.Name -Type NoteProperty -Value $p.Value -Force
      }
    }
    Write-Verbose "Current Config: $tempConfig"
    Write-Verbose "Setting custom configuration values."
    foreach ($p in $config.psobject.Properties) { 
      Write-Verbose "Property: $($p.Name); Value: $($p.Value)"
      if (!!$p.Value) {
        Write-Verbose "Setting $($p.Name) to $($p.Value)"
        $tempConfig | Add-Member -Name $p.Name -Type NoteProperty -Value $p.Value -Force
      }
    }
    $this.Configuration = $tempConfig
    Write-Verbose "Configuration Complete!"
  }

  # TODO Method to change value of property.
  # [PSCustomObject]Update([string]$PropName, [string]$PropValue) {}
}
