#Script: createOSdiskfromDiskRestore.ps1
#Function: McShera Consulting Azure Training Lab

#Date: 15/09/2017

#Createdby: Gavin McShera - gavin@mcshera.com

##########################################################

#References: 

#https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-create-managed-disk-from-vhd

##########################################################
#Convert restore vhd blobs to managed disks
$subscription = "McShera Consulting"
$location = "NorthEurope"
Write-Host "Recommend that disk Resource Group matches the previous VM"
$rgName = Read-Host -Prompt "Enter the resource group name for the new OS disk"

Login-AzureRmAccount

Set-AzureRmContext -SubscriptionName $subscription

#Disk Paramaters
$osDiskName = Read-Host -Prompt "Enter the name for the new OS Disk"
$OSDiskSize = "128"

#Source Storage Details
$storageAccountType = "StandardLRS"
$osDiskUri = "https://applrs01.blob.core.windows.net/vhds/app0120170915101924.vhd"

#Create new managed disk
$diskConfig = New-AzureRmDiskConfig -OsType Windows -DiskSizeGB $diskSize -AccountType $storageAccountType -Location $location -CreateOption Import -SourceUri $osDiskUri

New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $rgName -DiskName $osDiskName
