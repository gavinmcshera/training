#Script: createEnv.ps1
#Function: McShera Consulting/Westcoast Create Azure Training Lab
#Date: 25/03/17
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################
#References: 
# Note 1:
#Uses the Network Security Groups Template using mspnp/template-building-blocks from the AzureCAT - patterns & practices (PnP) Template Building Blocks project.
#provides a series of Azure Resource Manager templates you can use to deploy a collection of resources that, together, make up a building block for larger solutions.
#Source: https://raw.githubusercontent.com/mspnp/template-building-blocks/master/scenarios/networkSecurityGroups/azuredeploy.json 
##########################################################

#Variabes
$subscription = "<your subscription Name>"
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

#Create NSG for MGMT Network
#This will open RDP to the VM from internet
#Example of using existing Templates in GitHub and passing Template Parameter files
New-AzureRmResourceGroupDeployment -ResourceGroupName $ManagementResourceGroupNetwork -TemplateUri https://raw.githubusercontent.com/mspnp/template-building-blocks/master/scenarios/networkSecurityGroups/azuredeploy.json -templateParameterUriFromTemplate https://raw.githubusercontent.com/gavinmcshera/training/master/vnet/vnet-00-nsg.json

#Create MGMT VM
#You will be prompted for the following paramaters.  Complete as below to create mgmt01 as part of the demo. 
#adminUsername: <choose your own>
#adminPassword: <secure prompt, choose your own>
#dnsLabelPrefix: <choose your own dnsname> e.g. <you decide>.northeurope.cloudapp.azure.com
#existingVirtualNetworkName: vnet00
#existingVirtualNetworkResourceGroup: mgmt-rg
#subnetName: mgmt
#vmName: mgmt01
#vmIPaddr: 10.255.0.10
New-AzureRmResourceGroupDeployment -ResourceGroupName $ManagementResourceGroupNetwork -TemplateUri https://raw.githubusercontent.com/gavinmcshera/training/master/vm/vm-mgmt01.json
