#Script: createVPNTest
#Function: McShera Consulting/Test VNET-to-VNET Connection across regions
#Date: 05/07/2017
#Createdby: Gavin McShera - gavin@mcshera.com
##########################################################
#References: 
#Based on: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-vnet-vnet-rm-ps
##########################################################


#Variables
$Sub1 = "Replace_With_Your_Subcription_Name"

#Network 1 - vnet00
$RG1 = "eastus-rg"
$Location1 = "East US"
$VNetName1 = "vnet00"
$FESubName1 = "dmz"
$BESubName1 = "lan"
$GWSubName1 = "GatewaySubnet"
$VNetPrefix1 = "10.0.0.0/16"
$FESubPrefix1 = "10.0.255.0/24"
$BESubPrefix1 = "10.0.1.0/24"
$GWSubPrefix1 = "10.0.0.0/24"
$GWName1 = "vnet00-gw"
$GWIPName1 = "vnet00-gw-ip"
$GWIPconfName1 = "gwipconf1"
$VPNConnection1 = "vnet00tovnet01"

#Network 1 - vnet00
$RG2 = "austse-rg"
$Location2 = "australiasoutheast"
$VNetName2 = "vnet01"
$FESubName2 = "dmz"
$BESubName2 = "lan"
$GWSubName2 = "GatewaySubnet"
$VNetPrefix2 = "10.1.0.0/16"
$FESubPrefix2 = "10.1.255.0/24"
$BESubPrefix2 = "10.1.1.0/24"
$GWSubPrefix2 = "10.1.0.0/24"
$GWName2 = "vnet01-gw"
$GWIPName2 = "vnet01-gw-ip"
$GWIPconfName2 = "gwipconf2"
$VPNConnection2 = "vnet01tovnet00"

##########################################################

#Connect to Subscription
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $Sub1

#Create Resource Groups
New-AzureRmResourceGroup -Name $RG1 -Location $Location1
New-AzureRmResourceGroup -Name $RG2 -Location $Location2

##########################################################

#Create the Networks

##########################################################

#Subnets
$fesub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName1 -AddressPrefix $FESubPrefix1
$besub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName1 -AddressPrefix $BESubPrefix1
$gwsub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName1 -AddressPrefix $GWSubPrefix1
$fesub2 = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName2 -AddressPrefix $FESubPrefix2
$besub2 = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName2 -AddressPrefix $BESubPrefix2
$gwsub2 = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName2 -AddressPrefix $GWSubPrefix2

#Networks
New-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1 `
-Location $Location1 -AddressPrefix $VNetPrefix1 -Subnet $fesub1,$besub1,$gwsub1
New-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $RG2 `
-Location $Location2 -AddressPrefix $VNetPrefix2 -Subnet $fesub2,$besub2,$gwsub2

#Create Public IP for the Gateways
$gwpip1 = New-AzureRmPublicIpAddress -Name $GWIPName1 -ResourceGroupName $RG1 `
-Location $Location1 -AllocationMethod Dynamic
$gwpip2 = New-AzureRmPublicIpAddress -Name $GWIPName2 -ResourceGroupName $RG2 `
-Location $Location2 -AllocationMethod Dynamic

##########################################################

#Create the Gateways - This can take up to 45 minutes.  Be patient.

##########################################################

#Configuration
$vnet1 = Get-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$subnet1 = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwipconf1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName1 `
-Subnet $subnet1 -PublicIpAddress $gwpip1

$vnet2 = Get-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $RG2
$subnet2 = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet2
$gwipconf2 = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName2 `
-Subnet $subnet2 -PublicIpAddress $gwpip2
#Gateways
New-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1 `
-Location $Location1 -IpConfigurations $gwipconf1 -GatewayType Vpn `
-VpnType RouteBased -GatewaySku Basic

New-AzureRmVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2 `
-Location $Location2 -IpConfigurations $gwipconf2 -GatewayType Vpn `
-VpnType RouteBased -GatewaySku Basic

##########################################################

#Create the connection between VNETs

##########################################################

#Get the Gateways
$vnet00gw = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$vnet01gw = Get-AzureRmVirtualNetworkGateway -Name $GWName2 -ResourceGroupName $RG2

#Create the vnet connections

#vnet00 to vnet01
New-AzureRmVirtualNetworkGatewayConnection -Name $VPNConnection1 -ResourceGroupName $RG1 `
-VirtualNetworkGateway1 $vnet00gw -VirtualNetworkGateway2 $vnet01gw -Location $Location1 `
-ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'

#vnet01 to vnet00
New-AzureRmVirtualNetworkGatewayConnection -Name $VPNConnection2 -ResourceGroupName $RG2 `
-VirtualNetworkGateway1 $vnet01gw -VirtualNetworkGateway2 $vnet00gw -Location $Location2 `
-ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'

# Test connection status.  Might have to wait for status to move to Connected.
Get-AzureRmVirtualNetworkGatewayConnection -Name $VPNConnection1 -ResourceGroupName $RG1 | ft name,ConnectionStatus
Get-AzureRmVirtualNetworkGatewayConnection -Name $VPNConnection2 -ResourceGroupName $RG2 | ft name,ConnectionStatus

##########################################################

#Create Virtual Machines

##########################################################

#Variables

$vm1 = "vm000"
$vm1NIC = "vm000"
$vm1IP = "vm000-ip"
$vm2 = "vm001"
$vm2NIC = "vm001"
$vm2IP = "vm00-ip"

#Get vm1 subnet id
$vnet1 = Get-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$SubnetID1 = (Get-AzureRmVirtualNetworkSubnetConfig -Name ‘lan’ -VirtualNetwork $vnet1).Id

#Get vm2 subnet id
$vnet2 = Get-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $RG2
$SubnetID2 = (Get-AzureRmVirtualNetworkSubnetConfig -Name ‘lan’ -VirtualNetwork $vnet2).Id

##########################################################

#Create Public IP for NICs
$VMip1 = New-AzureRmPublicIpAddress -Name $vm1IP -ResourceGroupName $RG1 `
-Location $Location1 -AllocationMethod Dynamic
$VMip2 = New-AzureRmPublicIpAddress -Name $vm2IP -ResourceGroupName $RG2 `
-Location $Location2 -AllocationMethod Dynamic

# Create a virtual network card and associate with public IP address
$nic1 = New-AzureRmNetworkInterface -Name $vm1NIC -ResourceGroupName $RG1 `
    -SubnetId $SubnetID1 -PublicIpAddressId $VMip1.Id -Location $Location1
$nic2 = New-AzureRmNetworkInterface -Name $vm2NIC -ResourceGroupName $RG2 `
    -SubnetId $SubnetID2 -PublicIpAddressId $VMip2.Id -Location $Location2

#Create VM00
# Define a credential object for the localadmin password on servers
$cred = Get-Credential

# Create a virtual machine configurations
$vmConfig1 = New-AzureRmVMConfig -VMName $vm1 -VMSize Standard_A1_v2 | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName $vm1 -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic1.Id

$vmConfig2 = New-AzureRmVMConfig -VMName $vm2 -VMSize Standard_A1_v2 | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName $vm2 -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic2.Id

#Create the VMs
New-AzureRmVM -ResourceGroupName $RG1 -VM $vmConfig1 -Location $Location1
New-AzureRmVM -ResourceGroupName $RG2 -VM $vmConfig2 -Location $Location2
