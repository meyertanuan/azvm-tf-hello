# azvm-tf-hello
Deploy a simple Node hello.js to Azure VM using Terraform

## 1. Prerequisites:
- Azure CLI installed
- Terraform installed
- Azure account with free tier access
- SSH key generated (ssh-keygen -t rsa)
  - Generated keys (id_rsa and id_rsa.pub) must exist in C:\Users\<username>\.ssh
  
## 2. Deployment Steps:

Follow the steps provided in the Hello NodeJs App document. 

### 2a.	Azure CLI Authentication
$ az login
$ az account show

### 2b. Terraform Deployment
$ cd terraform/
$ terraform init
$ terraform validate
Expected: Success! The configuration is valid.
$ terraform plan
$ terraform apply –auto-approve
Expected: nodejs-app-rg with all associated resources is created.
Optional: visit http://portal.azure.com

### 2c. Transfer Setup Script

$ VM_PUBLIC_IP=$(az vm show -d -g nodejs-app-rg -n nodejs-vm --query publicIps -o tsv)

$ echo $VM_PUBLIC_IP
Sample result: 172.191.11.139

$ scp -i ~/.ssh/id_rsa scripts/setup.sh azureuser@$VM_PUBLIC_IP:~/setup.sh

$ ssh -i ~/.ssh/id_rsa azureuser@$VM_PUBLIC_IP

$ uname -a

$ chmod +x ~/setup.sh
$ sudo ~/setup.sh

Expected: hello.js is created in /opt/nodejs-app

## 3. Access the Hello App

- Navigate to http://<VM_PUBLIC_IP>:3000

## WARNING: When done, always destroy resources.
If "terraform destroy" does not work, you must remove the resource group (RG) outside Terraform.

- Azure CLI:
  - $ az group list --query "[].name"
  - $ az group delete -n nodejs-app-rg
- Azure Portal: 
    - Navigate to list of RGs
    - Select nodejs-app-rg
    - Delete RG
    - Enter name: nodejs-app-rg
    - Delete

## If "terraform destroy" does not remove NetworkWatcherRG automatically, repeat the above step above. 
$ az group delete -n NetworkWatcherRG
$ az group list --query "[].name"
Expected: should be EMPTY

## First, learn the deployment steps with 
- size = "Standard_F1" # Free tier VM size
## Then, for development and testing, replace with a bigger size such as:
- size = "Standard_B1s"  # Recommended tier for light workloads (budget: $5/month)

