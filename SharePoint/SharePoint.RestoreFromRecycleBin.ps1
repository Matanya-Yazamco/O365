<#PSScriptInfo
.VERSION 1.0
.GUID 97ed1acc-6fd2-401a-b438-4ba99fce3b2e
.AUTHOR rubik.junk@gmail.com
.COMPANYNAME BUSTRAMA
.PROJECTURI https://github.com/rubik951/PowerShell/blob/master/SharePoint/RestoreFromRecycleBin.ps1
#>

#Requires -Module SharePointPnPPowerShellOnline

<#
.DESCRIPTION

 This tool help you search through the SharePoint Recycle Bin and Restore the files you want more easily
 Instructions displayed while running the script

#>

Param()

if (Get-Module -ListAvailable -Name SharePointPnPPowerShellOnline) {
    Write-Output "SharePointPnPPowerShellOnline Module exists"
} else {
    Write-Output "Module does not exist"
    Write-Output "Installing..."
    Install-Module SharePointPnPPowerShellOnline
}
Clear-Host
Write-Output "############################################################"
Write-Output "###                                                      ###"
Write-Output "###                Sharepoint File Restore Tool          ###"
Write-Output "###                                                      ###"
Write-Output "### Copy the sharepoint link                             ###"
Write-Output "### Like this example:                                   ###"
Write-Output "### https://TENANT_HERE.sharepoint.com/sites/SITE_NAME   ###"
Write-Output "###                                                      ###"
Write-Output "############################################################"

Write-Output ""
$SharepointSite = Read-Host "Please enter sharepoint URL(Specific Site)"

Connect-PnPOnline -Url $SharepointSite -Credentials (Get-Credential)

$RecycleBin = (Get-PnPRecycleBinItem -FirstStage)

$Restore = 0
$display = 0



function Search($option) {
    Switch($option){
        1{
            $filter = Read-Host "Enter file name: "
            $Restore = $RecycleBin | Where-Object Title -Like "*$($filter)*"
            $display = $Restore | Select-Object -ExpandProperty DirNamePath Title, DeletedByName, DeletedDate
        }
        2{
            #Search file by exact name
        }
        3{
            $filter = Read-Host "Enter the desired name: "
            $Restore = $RecycleBin | Where-Object DeletedByName -Like "*$($filter)*"
            $display = $Restore | Select-Object -ExpandProperty DirNamePath Title, DeletedByName, DeletedDate
        }
        4{
            $filter = Read-Host "Enter the path: "
            $Restore = $RecycleBin | Where-Object {$_.DirNamePath.DecodedUrl -like "$($filter)*"}
            $display = $Restore | Select-Object -ExpandProperty DirNamePath Title, DeletedByName, DeletedDate
        }
    }

    if($display -eq 0){
        Write-Output "No results found"
    }else{
        $display
    }

    Write-Output ""
    Read-Host "Press Enter to continue"

    $yn = Read-Host "Would you like to restore now (Y/N) Where-Object"
    if(($yn -eq "Y") -or ($yn -eq "y")){
        Restore
    }else {
        Main
    }
}

function Restore {
    Write-Output "Restoring using search filter"

    $Restore | Restore-PnPRecycleBinItem

    Write-Output ""
    Read-Host "Press any key to continue"
    Main
}

function UpdateRecycleBin{
    $RecycleBin = (Get-PnPRecycleBinItem -FirstStage)
}

function Main {
    Clear-Host
    $welcome
    Write-Output ""
    Write-Output "1. Search for deleted items"
    Write-Output "2. Restore deleted items (choosing this option will restore the latest search)"
    Write-Output "3. Update Recycle Bin (Load 9999 items every time)"
    $option = Read-Host "Please Choose an option"

    Switch($option){
        1 {
            Write-Output ""
            Write-Output "Search by:"
            Write-Output "1. Like File Name"
            Write-Output "2. Exact File Name"
            Write-Output "3. Deleted By Name"
            Write-Output "4. Directory Path"
            $option = Read-Host "Please Choose an option"

            Search($option)
        }
        2 {
            Write-Output ""
            Restore
        }
        3{
            UpdateRecycleBin
        }
    }
}

$welcome = {
    "   ******************************************************************************************"
    "   ******************************************************************************************"
    "   ****                                                                                  ****"
    "   ****                       Sharepoint File Restore Tool                               ****"
    "   ****                                                                                  ****"
    "   ****                                                                                  ****"
    "   ****    ## Intructions ##                                                             ****"
    "   ****    1. Use the search to find the items you wish to restore                       ****"
    "   ****    2. When the search is done the results we'll be displayed                     ****"
    "   ****    3. If it was what you meant to restore, choose the restore option             ****"
    "   ****    4. Now choose the restore option, the restore remembers the search you made   ****"
    "   ****                                                                                  ****"
    "   ****                                                                                  ****"
    "   ******************************************************************************************"
    "   ******************************************************************************************"
    }
$welcome
Write-Output ""
Write-Output "1. Search for deleted items"
Read-Host "Press Enter to continue"
Search

##  אפשרות לשחזור ספציפי
##  טווח תאריכים

