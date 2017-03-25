#Script: CheckAV.ps1
#Usage: Check Microsoft Antimalware status on a single VM
#Created: 01/02/2017

#Login to Azure ARM
Add-AzureRmAccount

#Set the AtlasFX Subscription as context
Set-AzureRmContext -SubscriptionName "xxxxxx"

#Fill in the resouce group and the server you want to query
$resourceGroupName = "<resource group name>"
$vmname = "<vm name>"
Get-AzureRmVMExtension -ResourceGroupName $resourceGroupName –VMName $VMName -Name "IaaSAntimalware"