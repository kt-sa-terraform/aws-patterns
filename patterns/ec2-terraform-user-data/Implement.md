# Overview
When you install EC2 instance, you might want to install additional software/packages for that instance. It makes sure you have enough tools for using after ec2 server is provisioned.
In this lab
## 1. Architecture
![image](https://user-images.githubusercontent.com/74917008/234213520-723e69a0-b428-4eda-9c1c-936d6211076a.png)

### 1. Scenario
- Install software to EC2 after provisioning
- Get sensitive variables from AWS system manager parameters store
### 2. Describe
-  
-
### 3. Implement
- Create parameters in AWS system manager parameters store.
- Create user_data.sh which has variables in scripts, use  ${secret} in script.
- Create datasource which get value from parameters store
- Use templatefile fuction and pass variables to script
- run terraform

## 2. Terraform
### 1. How to install software during provisioning EC2
Provisioning EC2 and with pre-install parkages during provisioning can be done with following methods:

- provisioner remote-exec or local-exec 
- user_data:
    - user_data = file {}
    - user_data = templatefile {filename.tpl} or using template_file datasource
    - user_data = <<EOF  ----------- EOF
### note:
- how to use variables in user_data > use templatefile and pass terraform variables to script  
### 2. Input variables

### 3. Output

### 4. Deployment
- terraform plan
- terraform apply
