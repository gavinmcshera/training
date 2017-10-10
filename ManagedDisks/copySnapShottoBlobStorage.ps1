#Script: createOSdiskfromDiskRestore.ps1
#Function: McShera Consulting Azure Training Lab

#Date: 10/10/2017

#Createdby: Gavin McShera - gavin@mcshera.com

##########################################################

#References: 

#

##########################################################

$subscription = "McShera Consulting"

Login-AzureRmAccount
Set-AzureRmContext -SubscriptionName $subscription

#Destination storage account and settings
$storageAccountName = "applrs01"
$storageAccountKey = “j0mmhZdPT+PZD4XnhUcyF8dYoSgieFLU57gFqqS76ZAPxRCArbUYTc7fnWO/3efZDanYezWksINxfTQeAKtapQ==”
$destContainer = “images”
$blobName = “app01_image.vhd”

#Snapshot URI
$absoluteUri = “https://md-qtp3v1sjxx3g.blob.core.windows.net/fqwnc5gfbzp1/abcd?sv=2016-05-31&sr=b&si=aa0d77b4-2ac6-4fae-a9e2-9bc74a3badb7&sig=toK82k0i0atw5Rv%2F4RzzTUYwMo5uChRoO5zKfwENqDY%3D”

#Set the destination storage account
$destContext = New-AzureStorageContext –StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

#Start the copy process.  This can take some time.
Start-AzureStorageBlobCopy -AbsoluteUri $absoluteUri -DestContainer $destContainer -DestContext $destContext -DestBlob $blobName

#Check the status of the copy
#$blob=Get-AzureStorageBlob -Context $destContext -Container "images"
#Get-AzureStorageBlobCopyState -CloudBlob $blob.ICloudBlob -Context $destContext

