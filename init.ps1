az group create --location westeurope --name terraformexample-infrastructure
az storage account create --name terraformexampleinfrastructure --resource-group terraformexample-infrastructure --location westeurope --sku Standard_LRS
az storage container create --name tfstate --account-name terraformexampleinfrastructure

$ENV:ARM_ACCESS_KEY = ((az storage account keys list --account-name terraformexampleinfrastructure --resource-group terraformexample-infrastructure) | ConvertFrom-Json)[0].value

Write-Host "Storage Account Key: $accessKey"