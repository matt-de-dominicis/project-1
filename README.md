# project-1
This project utilizes Terrform for multi-cloud deployment to create and deploy infrastructure to two cloud providers: Azure and AWS. The resources created are the following 
- users in AzureAD and in AWS Identity and Access Management (IAM)
- two Azure S3 buckets using Terraform's count argument
- an Azure resource group which contains the following resources:
    - an Azure storage account with Locally Redundant Storage
    - an Azure Virtual Machine, along with the resources necessary for the VM like a virtual network, subnet, and a network interface. 