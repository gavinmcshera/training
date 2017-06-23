#Script: createNetwork.ps1
#Function: McShera Consulting/Westcoast Azure Training Lab
#Date: 25/03/17
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################
#References: 
#Network Security Groups Template using mspnp/template-building-blocks from the AzureCAT - patterns & practices (PnP) Template Building Blocks project.
#provides a series of Azure Resource Manager templates you can use to deploy a collection of resources that, together, make up a building block for larger solutions.
##########################################################

#Variabes
$subscription = "McShera Consulting"
$ManagementResourceGroupNetwork = "mgmt-rg"
$ProductionResourceGroupNetwork = "prd-network-rg"
$Location = "North Europe"

#Login to AzureRM and select subscription
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionName $subscription

#Create the resource groups for the networks
New-AzureRmResourceGroup -Name $ManagementResourceGroupNetwork -Location $Location
New-AzureRmResourceGroup -Name $ProductionResourceGroupNetwork -Location $Location

#Create the Networks using JSON templates from GitHub
New-AzureRmResourceGroupDeployment -ResourceGroupName $ManagementResourceGroupNetwork -TemplateUri https://raw.githubusercontent.com/gavinmcshera/training/master/vnet/vnet-00.json
New-AzureRmResourceGroupDeployment -ResourceGroupName $ProductionResourceGroupNetwork -TemplateUri https://raw.githubusercontent.com/gavinmcshera/training/master/vnet/vnet-01.json

#-TemplateParameterFile
#-TemplateFile
#Create NSG for MGMT Network
New-AzureRmResourceGroupDeployment -ResourceGroupName $ProductionResourceGroupNetwork -TemplateUri https://raw.githubusercontent.com/mspnp/template-building-blocks/master/scenarios/networkSecurityGroups/azuredeploy.json -templateParameterUriFromTemplate https://raw.githubusercontent.com/gavinmcshera/training/master/vnet/vnet-00-nsg.json
