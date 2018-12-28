# connect to Exchange online
if (Get-Module -ListAvailable -Name MSOnline) {
    Write-Host "Module exists"
} else {
    Write-Host "Module does not exist"
    Write-Host "Importing..."
    Import-Module MSOnline
}

function Connect-Exchange365 {
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session 
    Connect-MsolService -Credential $UserCredential    
}

function End-Exchange365 {
    Get-PSSession | ? ComputerName-like "*outlook.com" | Remove-PSSession
}