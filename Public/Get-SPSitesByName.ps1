Function Invoke-SessionCommand {
  <#
  .SYNOPSIS
  .DESCRIPTION
  .PARAMETER Credential
  .PARAMETER SPSiteUrlPattern
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
    # root sharepoint url
    [Parameter(ValueFromPipelineByPropertyName = $True, Mandatory)]
    [string]
    $SPRootUrl,
    # string to search sites by, use wildcards to get more results
    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [string]
    $SPSiteUrlPattern = '*'
  )
  BEGIN
  {
    Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
  }
  PROCESS
  {
    $webapp = Get-SPWebApplication $SPRootUrl
    $SPSites = $webapp.Sites | Where-Object { $_.Url -like $SPSiteUrlPattern }
    $SPSites
  }
  END
  {
    Remove-PSSnapin Microsoft.SharePoint.Powershell
  }
}