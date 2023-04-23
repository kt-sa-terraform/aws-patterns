variable "internal_domain" {
  type = string
  default     = ""
}

variable "namespaces" {
  type = list(string)
}

variable "eks_external_route53dns_role" {
  type = string
  default     = ""
}

