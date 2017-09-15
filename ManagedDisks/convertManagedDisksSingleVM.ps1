$rgName = "myResourceGroup"
$vmName = "myVM"
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force
