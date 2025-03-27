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


## WARNING: You must always end the deployment with "terraform destroy".
If that does not work, you must remove the resource group (RG).

(a) Azure CLI: az group delete "<name>"
(b) Azure Portal: 
    - Navigate to list of RGs
    - Select nodejs-app-rg
    - Delete RG
    - Enter name: nodejs-app-rg
    - Delete
(c) Repeat either (a) or (b) for NetworkWatcherRG

## First, learn the deployment steps with 
- size = "Standard_F1" # Free tier VM size
## Then, for development and testing, replace with a bigger size such as:
- size = "Standard_B1s"  # Recommended tier for light workloads (budget: $5/month)

