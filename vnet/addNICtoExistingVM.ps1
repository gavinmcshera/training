#Script: addNICtoExistingVM
#Function: McShera Consulting
#Date: 13/07/2017
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################

#Variables
$subscription = "McShera Consulting"
$vmName = ‘vm000’ 
$vnetName = ‘vnet00’ 
$RG = ‘eastus-rg’ 
$subnetName = ‘lan’ 
$nicName = ‘vm000-NIC2’ 
$location = "East US" 
$ipAddress = ’10.0.0.6’


##########################################################

#Connect to Subscription
Add-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $subscription
##########################################################

#Get the VM we want to modify
$myVm = Get-AzureRmVM -Name $vmName -ResourceGroupName $RG

#One NIC must be primary.  Setting the first NIC
$myVM.NetworkProfile.NetworkInterfaces.Item(0).Primary = $True

#Get the VMs network configuraiton to identify the $subnetID
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $RG

#Figure out the $subnetID by first NIC.
$subnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet).Id

#Create a new NIC before adding to the VM
New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $RG -Location $location -SubnetId $subnetID

#Get the new NIC
$myNIC =  Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $RG

#Add the NIC to the VMs configuration
$myVm = Add-AzureRmVMNetworkInterface -VM $myVm -Id $myNIC.Id

#Set new NIC to False
$myVM.NetworkProfile.NetworkInterfaces.Item(1).Primary = $false

#Update the VM
Update-AzureRmVM -VM $myVm -ResourceGroupName $RG
