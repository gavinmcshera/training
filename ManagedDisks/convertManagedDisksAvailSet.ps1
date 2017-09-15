#Script: convertManagedDisksAvailSet.ps1
#Function: McShera Consulting Azure Training Lab
#Date: 15/09/2017
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################
#References: 
#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/convert-unmanaged-to-managed-disks
##########################################################

Write-Host "This process will stop the virtual machine before converting to managed disks"
Write-Host "This process is for VMs in an Availabilit Set"

#Variabes
$subscription = "McShera Consulting"
$AvailSetName = Read-Host -Prompt "Enter the target Availability Set"
$AvailSetRGName = Read-Host -Prompt "Enter the target resource group name for the Availability Set"
$VMResourceGroupName = Read-Host -Prompt "Enter target VM resource group"
$vmName = Read-Host -Prompt "Enter target VM resource group"

#Login to AzureRM and select subscription
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionName $subscription

#Update the Availability Set to work with Managed Disks
$avSet = Get-AzureRmAvailabilitySet -ResourceGroupName $AvailSetRGName -Name $AvailSetName
Update-AzureRmAvailabilitySet -AvailabilitySet $avSet -Sku Aligned

#Get the new Availability Set object
$avSet = Get-AzureRmAvailabilitySet -ResourceGroupName $AvailSetRGName -Name $AvailSetName

#Stop each VM in the set and convert their disks
foreach($vmInfo in $avSet.VirtualMachinesReferences)
{
  $vm = Get-AzureRmVM -ResourceGroupName $VMResourceGroupName | Where-Object {$_.Id -eq $vmInfo.id}
  Stop-AzureRmVM -ResourceGroupName $VMResourceGroupName -Name $vm.Name -Force
  ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $VMResourceGroupName -VMName $vm.Name
  Start-AzureRmVM -ResourceGroupName $VMResourceGroupName -Name $vm.Name
}
