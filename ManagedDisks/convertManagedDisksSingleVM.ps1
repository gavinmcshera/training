#Script: convertManagedDisksSingleVM.ps1
#Function: McShera Consulting/Westcoast Azure Training Lab
#Date: 15/09/2017
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################
#References: 
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/convert-unmanaged-to-managed-disks
##########################################################

Write-Host "This process will stop the virtual machine before converting to managed disks"
Write-Host "This process will only work for single VMs not in availability sets"

#Variabes
$subscription = Read-Host -Prompt "Enter Subscription Name"
$ResourceGroupName = Read-Host -Prompt "Enter target VM resource group"
$vmName = Read-Host -Prompt "Enter target VM resource group"

#Login to AzureRM and select subscription
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionName $subscription

#Stop the VM
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName -Force

#Do the conversion
ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $ResourceGroupName -VMName $vmName

#Start the VM
Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
