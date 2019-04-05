Function Invoke-SessionCommand {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER ComputerNames
  .PARAMETER RunConcurrent
  .PARAMETER ScriptBlock
  .EXAMPLE
  #>
  [cmdletbinding()]
  param(
    # Credential
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [pscredential]
    $Credential,
    # Computer Names to run command on
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory)]
    [string[]]
    $ComputerNames,
    # if switch is present this will run on all servers at the same time, otherwise it will iterate through each
    [Parameter()]
    [switch]
    $RunConcurrent,
    # Script to run on the server
    [Parameter(Mandatory)]
    [scriptblock]
    $ScriptBlock
  )
  BEGIN
  {
    if (!$Credential) {
      $Credential = Get-Credential
    }
    if ($RunConcurrent) {
      $session = New-PSSession -ComputerName $ComputerNames -Credential $Credential # -Authentication Credssp
    }
    else {
      [System.Management.Automation.Runspaces.PSSession[]]$sessions = foreach ($cn in $ComputerNames) {
        New-PSSession -ComputerName $cn -Credential $Credential # -Authentication Credssp
      }
    }
  }
  PROCESS
  {
    if ($RunConcurrent) {
      Invoke-Command -Session $session -ScriptBlock $ScriptBlock
    }
    else {
      $sessions | ForEach-Object { Invoke-Command -Session $_ -ScriptBlock $ScriptBlock }
    }
  }
  END
  {
    if ($RunConcurrent) {
      Remove-PSSession -Session $session
    }
    else {
      Remove-PSSession -Session $sessions
    }
  }
}