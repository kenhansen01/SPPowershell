class SPServerSession {
  [System.Management.Automation.Runspaces.PSSession]$Session

  SPServerSession() {
    $wmc = Get-WSManCredSSP
    if ($wmc[0] -notlike "*wsman/`*") {
      Enable-WSManCredSSP -Role Client -DelegateComputer "*" -Force -Verbose
    }
  }
  
  [void]Open ([String]$ServerName, [PSCredential]$Credential) {
    Write-Verbose "Ensure $ServerName is able to accept credSSP."
    $wsManCredRemote = Invoke-Command -ComputerName $ServerName -ScriptBlock { Get-WSManCredSSP } -Credential $Credential
    Write-Host "credSSP response is $wsManCredRemote"
    if($wsManCredRemote[1] -notlike "This computer is configured to receive credentials *")
    {
      Invoke-Command -ComputerName $ServerName -ScriptBlock { Enable-WSManCredSSP -Role "Server" -Force } -Credential $Credential
    }

    Write-Verbose "Opening session for: $ServerName"
    $this.Session = New-PSSession -ComputerName $ServerName -Authentication Credssp -Credential $Credential
    Write-Host "This session is $($this.Session)"
  }

  [void]Close () {
    Write-Verbose "Disable CredSSP on server."
    Invoke-Command -Session $this.Session -ScriptBlock { Disable-WSManCredSSP -Role "Server" }
    Write-Verbose "Closing session: $($this.Session.Id)"
    Remove-PSSession $this.Session.Id
  }

  [void]Delete () {
    Disable-WSManCredSSP -Role Client
  }

}
