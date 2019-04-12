# How-To provision the infrastructure

## Install Terraform (CLI)

https://learn.hashicorp.com/terraform/getting-started/install.html

## Init infrastructure storage account

Requirements: Azure CLI >= 2.0.52  
Login with your personal account `az login` then initialize the storage account for the terraform state by running:

```
./init.ps1
```

## Navigate to the desired environment directory

```
cd .\environments\dev
```

## Terraform init

Run `init` in order to set the tfstate to the backend in azure.

```
terraform init
```


## Provision environment infrastructure

Terraform plan will show you changes that "would" be applied depending on the current state of the infrastructure in azure.  

```
terraform plan
```

if you are ok with those changes go ahead with `apply` which need an additional approval (yes/no)

```
terraform apply
```
