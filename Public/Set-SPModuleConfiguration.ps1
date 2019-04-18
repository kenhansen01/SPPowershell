Function Set-SPModuleConfiguration {
  <#
  .SYNOPSIS
    Loads configuration for the module and ensures proper PnP is loaded.
  .DESCRIPTION
    Loads configuration for the module. Optionally merges custom config settings overriding defaults.
  .PARAMETER CustomConfig
    Add this switch to apply custom configuration changes.
  .PARAMETER CustomConfigObject
    Hashtable with configuration data. Overrides existing values, adds new values.

    EX: [pscustomobject]@{
      SPEnvironment = "2013"
      Proxy = $false
      SPUrl = "http://my.cool.site"
    }
  .PARAMETER ConfigFile
    Location of  custom config file. 

    EX: "C:\Users\ME\Documents\Powershell\config.psd1"
  .EXAMPLE
    Set-SPModuleConfiguration -CustomConfig -CustomConfigObject $CustomConfigObject -ConfigFile $ConfigFile
  #>
  [cmdletbinding()]
  param(
    # Custom Config
    [Parameter()]
    [switch]
    $CustomConfig,
    # Custom Config Object
    [Parameter()]
    [pscustomobject]
    $CustomConfigObject,
    # Config File Location
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $ConfigFile = ".\Public\Config.psd1"
  )
  BEGIN {}
  PROCESS
  {
    Write-Verbose "Config File Location: $ConfigFile"
    if (!$ConfigFile) {
      $ConfigFile = ".\Public\Config.psd1"
    }
    if (!$CustomConfig) {
      $Script:config = ([SPConfigure]::new($ConfigFile)).Configuration
     } else {      
       
       $Script:config = ([SPConfigure]::new($CustomConfigObject, $ConfigFile)).Configuration
     }
     write-verbose "Ensure SharePointPnPPowerShell$($config.SPEnvironment) Exists"
     if (!(Get-Module "SharePointPnPPowerShell$($config.SPEnvironment)")) {
       $config | Set-PnPPowershell -Verbose:$VerbosePreference
     }
     Write-Verbose $config
  }
  END {}
}