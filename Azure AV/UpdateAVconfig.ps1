#Script: CheckAV.ps1
#Usage: Check Microsoft Antimalware status on a single VM
#Created: 01/02/2017

#Login to Azure ARM
Add-AzureRmAccount

#Set the AtlasFX Subscription as context
Set-AzureRmContext -SubscriptionName "<Subscription name>"

#Fill in the resouce group and the server you want to query
$resourceGroupName = "<resource group name>"
$vmname = "<vm name>"
$location= “North Europe”
$MSAVConfigfile = Get-Content "C:\Scripts\Azure AV\avconfig_dc.json" -Raw
$allVersions= (Get-AzureRmVMExtensionImage -Location $location -PublisherName “Microsoft.Azure.Security” -Type “IaaSAntimalware”).Version
$typeHandlerVer = $allVersions[($allVersions.count)–1]
$typeHandlerVerMjandMn = $typeHandlerVer.split(“.”)
$typeHandlerVerMjandMn = $typeHandlerVerMjandMn[0] + “.” + $typeHandlerVerMjandMn[1]
$SettingsString = ‘{ “AntimalwareEnabled”: true}’;

Set-AzureRmVMExtension -ResourceGroupName $resourceGroupName -VMName $VMName -Name "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -ExtensionType "IaaSAntimalware" -TypeHandlerVersion $typeHandlerVerMjandMn -SettingString $MSAVConfigfile -Location $location