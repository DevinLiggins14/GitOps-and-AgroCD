<table>
  <tr>
    <td><h1> GitOps with ArgoCD </h1></td>
    <td>
      <p align="right">
        <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="Docker" width="60" height="60"/> 
        <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/terraform/terraform-original.svg" alt="Terraform" width="60" height="60"/> 
        <img src="https://www.vectorlogo.zone/logos/kubernetes/kubernetes-icon.svg" alt="Kubernetes" width="60" height="60"/> 
        <img src="https://www.vectorlogo.zone/logos/circleci/circleci-icon.svg" alt="CircleCI" width="60" height="60"/> 
        <img src="https://www.vectorlogo.zone/logos/argoprojio/argoprojio-icon.svg" alt="ArgoCD" width="60" height="60"/> 
        <img src="https://www.vectorlogo.zone/logos/amazon_eks/amazon_eks-icon.svg" alt="Amazon EKS" width="60" height="60"/>
      </p>
    </td>
  </tr>
</table>

---

<h3 align="left">Project Overview</h3>


<p align="center">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="docker" width="40" height="40"/> 🐳 Dockerizing the Todo Application: Containerize the Todo app for efficient deployment and management.
  <br />
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/amazonwebservices/amazonwebservices-original-wordmark.svg" alt="aws" width="40" height="40"/> ☁️ Provisioning EKS Kubernetes Cluster with Terraform: Provision an EKS cluster on AWS using Terraform.
  <br />
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/circleci/circleci-plain-wordmark.svg" alt="circleci" width="40" height="40"/> 🔄 Implementing CI with CircleCI: Set up a robust CI pipeline with CircleCI for automated code integration.
  <br />
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/kubernetes/kubernetes-original.svg" alt="kubernetes" width="40" height="40"/> 🌐 GitOps with ArgoCD: Automate Kubernetes app deployment with GitOps using ArgoCD.
  <br />
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bash/bash-original.svg" alt="bash" width="40" height="40"/> 🛠️ Fixing Errors in Real-Time: Troubleshoot and resolve common errors encountered during the project.
</p>

---

<h3 align="left">By the End of This Project, You'll Master:</h3>
<ul>
  <li>Dockerizing applications for container-based deployment.</li>
  <li>Infrastructure as Code (IaC) with Terraform for provisioning EKS clusters.</li>
  <li>Continuous Integration and Delivery (CI/CD) pipelines with CircleCI.</li>
  <li>GitOps and automated deployments using ArgoCD.</li>
</ul>

### **Prerequisites**  
- Linux Server that can support the project
- Have an [AWS account](https://aws.amazon.com/console/)
- Install [terraform](https://developer.hashicorp.com/terraform/install).  


 ##  Step 1: Containerize the TODO application using Docker 

<br/>  First we will need to create an IAM user that will we will use to create and manage resources with terraform (Note: Make sure to safely store the credentials). <br/>
<br/> If a user already exsists within your organization account that you would like to use then you can simply generate a new a new access key and secret <br/> 

<img src="https://github.com/user-attachments/assets/706f8779-9c38-4e46-a808-dc3eccfec2df"/>

<br/> Next log into the [aws CLI](https://aws.amazon.com/cli/) as that user by running `aws configure` <br/> 


<br/> The next step is to run `git clone` and clone this repo locally. cd into /worker_scripts. (Note: also make sure to create and configure the the`backend.tf` with an S3 bucket and dyanmoDB table with a partition string). Here  <br/>

```HCL
# create VPC
module "VPC" {
  source           = "../modules/vpc"
  REGION           = var.REGION
  PROJECT_NAME     = var.PROJECT_NAME
  VPC_CIDR         = var.VPC_CIDR
  PUB_SUB1_CIDR    = var.PUB_SUB1_CIDR
  PUB_SUB2_CIDR    = var.PUB_SUB2_CIDR
  PRI_SUB3_CIDR    = var.PRI_SUB3_CIDR
  PRI_SUB4_CIDR    = var.PRI_SUB4_CIDR
}

# create NAT GATEWAY
module "Nat-GW" {
  source           = "../modules/Nat-GW"
  IGW_ID           = module.VPC.IGW_ID
  VPC_ID           = module.VPC.VPC_ID
  PUB_SUB1_ID      = module.VPC.PUB_SUB1_ID
  PUB_SUB2_ID      = module.VPC.PUB_SUB2_ID
  PRI_SUB3_ID      = module.VPC.PRI_SUB3_ID
  PRI_SUB4_ID      = module.VPC.PRI_SUB4_ID
}

# create IAM
module "IAM" {
  source           = "../modules/IAM"
  PROJECT_NAME     = var.PROJECT_NAME
}

# create EKS Cluster
module "EKS" {
  source               = "../modules/EKS"
  PROJECT_NAME         = var.PROJECT_NAME
  EKS_CLUSTER_ROLE_ARN = module.IAM.EKS_CLUSTER_ROLE_ARN
  PUB_SUB1_ID        = module.VPC.PUB_SUB1_ID
  PUB_SUB2_ID        = module.VPC.PUB_SUB2_ID
  PRI_SUB3_ID        = module.VPC.PRI_SUB3_ID
  PRI_SUB4_ID        = module.VPC.PRI_SUB4_ID
}

# create Node Group
module "NodeGroup" {
  source               = "../modules/NodeGroup"
  NODE_GROUP_ARN  = module.IAM.NODE_GROUP_ROLE_ARN
  PRI_SUB3_ID          = module.VPC.PRI_SUB3_ID
  PRI_SUB4_ID          = module.VPC.PRI_SUB4_ID
  EKS_CLUSTER_NAME     = module.EKS.EKS_CLUSTER_NAME
}
```

This `main.tf` file will serve as the primary configuration for provisioning AWS infrastructure using Terraform. <br/>  
It leverages custom modules to create a VPC, NAT Gateway, IAM roles, an EKS cluster, and node groups. <br/>  

Each module is designed to be reusable and modular, ensuring scalability and maintainability for the project. <br/>  
This file acts as the backbone of the infrastructure setup, connecting all components seamlessly.

<br/> The next step is to run `terraform init` -->  `terraform plan` --> `terraform apply --auto-approve` to provision the infrastructure: <br/>




## Step 2:


<br/> Now run `aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME` <br/>

<img src=""/>

<br/> <br/>

<img src=""/>

<br/> <br/>

<img src=""/>

<br/> <br/>

<img src=""/>

<br/> <br/>

<img src=""/>



## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

## Step :

<br/> <br/> 

<br/> <br/> 

<img src=""/>

<br/> <br/>

