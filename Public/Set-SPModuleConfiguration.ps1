Function Set-SPModuleConfiguration {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER CustomConfig
  .PARAMETER CustomConfigObject
  .PARAMETER ConfigFile
  .EXAMPLE
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