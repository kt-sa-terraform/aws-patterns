variable "vpc_config" {
  type = object({
    vpc_name = string
    cidr_block  = string
    subnet_bits = number #for subnetting
  })
#  default = {
#    vpc_name = "general"
#    cidr_block  = "10.20.0.0/16"
#    subnet_bits = 6
#  }
}
