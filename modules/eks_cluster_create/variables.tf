variable "vpc_config" {
  type = object({
    cidr_block  = string
    subnet_bits = number #for subnetting
  })
#  default = {
#    cidr_block  = "10.10.0.0/16"
#    subnet_bits = 6
#  }
}

variable "cluster_name" {
  type        = string
#  default     = "dev-eks"
  description = "name of eks cluster"
}

variable "cluster_version" {
  type        = string
#  default     = "1.22"
  description = "version of eks cluster"
}

#variable "cluster_endpoint_private_access" {
#  type        = bool
#  default     = false
#  description = "eks is accessed only within vpc"
#}

variable "cluster_endpoint_public_access" {
  type        = bool
#  default     = true
  description = "eks is accessed only within vpc"
}

variable "environment" {
  type        = string
#  default     = "dev"
  description = "environment for tags"
}

# requried
variable "aws_auth_user" {
  type        = string
#  default     = "eks-admin"
  description = "username which is mapped to eks"
}

variable "aws_auth_role" {
  type        = string
#  default     = "eks-admin-role"
  description = "role which is mapped to eks"
}

variable "aws_account_id" {
  type        = string
#  default     = "641027422378"
  description = "current accountid"
}

variable "public_key" {
  type        = string
#  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF44zwBg/EGK/FUeXeoM8w36aqg7kWF13yfju7eY9bpo kieunv"
  description = "public key for ssh to worker nodes"
}

variable "workergroup" {
  type = any
#  default = {
#    instance_type = "t3.large"
#    disk_size      =  20
#    capacity_type  = "SPOT"
#    desired_size   = 2
#  }
}

variable internal_dns_hostzone {
  type        = string
  description = "internal dns"
}
