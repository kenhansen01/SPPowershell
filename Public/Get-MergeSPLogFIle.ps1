Function Get-MergeSPLogFile {
  <#
  .SYNOPSIS
    Get MergeLog
  .DESCRIPTION
    Get MergeLog
  .PARAMETER ServerName
    The servers to run PSConfig on, these should be in order of Updates
  .PARAMETER Credential
    User Creds
  .PARAMETER CorrelationID
    Correlation ID for merge log
  .PARAMETER FilePath
    Location to save the log
  .EXAMPLE
    Get-MergeSPLogFile -ServerName FANCYSERVER1 -Credential ameren\q140889 -CorrelationID d64ee39e-a93b-90d6-780a-e9362eb633be

    Runs the command to get mergelog.
  #>
  [cmdletbinding()]
  param(
    # Correlation
    [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Position=2)]
    [guid[]]
    $CorrelationID,
    # Credential
    [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Position=1, Mandatory)]
    [pscredential]
    $Credential,
    # Server Names
    [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Position=0, Mandatory)]
    [string]
    $ServerName,
    # File Path
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $FilePath = "\\peso6shrwfgv\logs\mergedlog.log"
  )
  BEGIN
  {
    Write-Verbose "Initial setup for Server Session"
    $SPServerSession = [SPServerSession]::new()
  }
  PROCESS
  {
    [ScriptBlock]$AddSnap = { Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue }
    
    [ScriptBlock]$MergeLog = { 
      $fPath = $args[0]
      $cID = $args[1]
      Merge-SPLogFile -Path $fPath -Overwrite -Correlation $cID
    }
      
    $SPServerSession.Open($ServerName, $Credential)  
    # Add snapin to session
    Invoke-Command -Session $SPServerSession.Session -ScriptBlock $AddSnap
    Invoke-Command -Session $SPServerSession.Session -ScriptBlock $MergeLog -ArgumentList $FilePath, $CorrelationID
    $SPServerSession.Close()
  }
  END
  {
    $SPServerSession.Delete()
  }
}
