Function Set-PSConfigServer {
  <#
  .SYNOPSIS
    Run PSConfig Command on Remote Servers
  .DESCRIPTION
    Runs PSConfig on each server.
  .PARAMETER ServerNames
    The servers to run PSConfig on, these should be in order of Updates
  .PARAMETER Credential
    User Creds
  .EXAMPLE
    Set-PSConfigServer -ConfigFile "C:\Users\q140889\OneDrive for Business\Documents\PowerShell\Config.psd1" -CustomConfig -Credential ameren\q140889 -Verbose

    Runs the command on the servers found in the Config File.
  #>
  [cmdletbinding()]
  param(
    # config file custom location
    [Parameter(ValueFromPipelineByPropertyName = $True, ValueFromPipeline, Position=0)]
    [string]
    $ConfigFile,
    # Custom Config
    [Parameter()]
    [switch]
    $CustomConfig,
    # Credential
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [pscredential]
    $Credential,
    # Server Names
    [Parameter(ValueFromPipelineByPropertyName = $True, ValueFromPipeline)]
    [string[]]
    $ServerNames
  )
  BEGIN
  {
    $customConfigObject = [PSCustomObject]@{
      Credential = $Credential
      ServerNames = $ServerNames
    }
    if(!$config -or !!$ConfigFile -or $CustomConfig) {
      Set-SPModuleConfiguration -CustomConfig:$CustomConfig -CustomConfigObject $customConfigObject -ConfigFile $ConfigFile
    }
    if ($config.Credential) {
      $cred = $config.Credential 
    } else {
      Write-Verbose "Get Credentials"
      $cred = Get-Credential
    }
    Write-Verbose "Initial setup for Server Session"
    $SPServerSession = [SPServerSession]::new()
  }
  PROCESS
  {
    [ScriptBlock]$AddSnap = { Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue }
    
    [ScriptBlock]$PSConfig = { PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures }
    
    [ScriptBlock]$TestPSConfig = {
      $PSConfigLogLocation = $((Get-SPDiagnosticConfig).LogLocation) -replace "%CommonProgramFiles%","$env:CommonProgramFiles"
      $PSConfigLog = Get-ChildItem -Path $PSConfigLogLocation | Where-Object {$_.Name -like "PSCDiagnostics*"} | Sort-Object -Descending -Property "LastWriteTime" | Select-Object -first 1
      if ($null -eq $PSConfigLog)
      {
        New-Object PSCustomObject -Property @{PSConfigResult = "Not Found"}
      }
      else
      {
        # Get error(s) from log
        $PSConfigLastError = $PSConfigLog | select-string -SimpleMatch -CaseSensitive -Pattern "ERR" | Select-Object -Last 1
        if ($null -eq $PSConfigLastError)
        {
          New-Object PSCustomObject -Property @{PSConfigResult = "Success"}
        }
        else
        {
          New-Object PSCustomObject -Property @{PSConfigResult = $PSConfigLastError}
        }
      }
    }

    function RunPSConfig {
      Invoke-Command -Session $SPServerSession.Session -ScriptBlock $PSConfig
      $test = Invoke-Command -Session $SPServerSession.Session -ScriptBlock $TestPSConfig
      Write-Host "Test Result: $($test.PSConfigResult)"
      if ($test.PSConfigResult -ne "Success") {
        $tryAgain = Read-Host -Prompt "PSConfig failed would you like to try again? Y for yes, N for no: "
        if ($tryAgain.ToLower() -eq "y")
        {
          RunPSConfig
        }
        else
        {
          $stopLoop = Read-Host -Prompt "Do you want to stop this command? Y for yes, N for no: "
          if ($stopLoop.ToLower() -eq "y") { break }
        }
      }  
    }
      
    foreach ($server in $config.ServerNames) {
      $SPServerSession.Open($server, $cred)
      
      # Add snapin to session
      Invoke-Command -Session $SPServerSession.Session -ScriptBlock $AddSnap
      RunPSConfig
      $SPServerSession.Close()
    }
  }
  END
  {
    $SPServerSession.Delete()
  }
}
