
variable instance_type {
  type        = string
}

variable ami_id {
  type        = string
}
variable instance_name {
  type        = string
}

variable "ec2_subnet_id" {
  type = string
}

variable "ec2_key" {
  type = string
}

variable "monitoring" {
  type = bool
}

variable "create_Elastic_IP" {
  type = bool
  default = false
}

variable "create_additional_volume" {
  type = bool
  default = false
}

variable "ebs_add_availability_zone" {
  type = string
  default = "null"
}

variable root_volume_size {
  type        = number
  default     = 20
}

variable add_ebs_volume_size {
  type        = number
  default     = 20
}

variable "user_data_script" {
  type = string
  default=""
}

variable "user_data" {
  type = string
  default = ""
}

variable "vpc_security_group_ids" {
  type        = list
  description = "list of sg_id"
  default     = []
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}