# SharePoint Powershell

## How to use this

Download the files. Ideally to an approved powershell module location, like %ProgramFiles%\WindowsPowerShell\Modules. Other locations work, but you'll have to google that process (it's easy, just need full location of the module).

From an elevated powershell session

```PowerShell
Import-Module SPPowershell
```

## The default config file is phony!

So before importing the module, either change the values to work for your environment or always pass a custom location for a file you create on your machine.

## An Example

Assuming I have a config file Config.psd1

```PowerShell
# Get relevant Urls
$siteUrls = (Get-SPSiteCollection -ConfigFile "C:\User\Me\Documents\Config.psd1" -CustomConfig -ByUrl | Select Url).Url
# At each url, ensure the group exists, has permissions and includes users
$siteUrls | Set-SiteGroupUser
```
Neat!