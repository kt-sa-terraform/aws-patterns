# Overview

## 1. Architecture

### 1. Scenario
### 2. Describe
### 3. Implement


## 2. Terraform


### 1. How to install software during provisioning EC2
Provisioning EC2 and with pre-install parkages during provisioning can be done with following methods:

- provisioner remote-exec or local-exec 
- user_data:
    - user_data = file {}
    - user_data = templatefile {filename.tpl}
    - user_data = <<EOF  ----------- EOF
### note:
- how to use variables in user_data
  
### 2. Input variables
### 3. Output
### 4. Deployment