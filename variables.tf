variable "regions" {
  description = "List of regions to deploy"
  type        = list(any)
  default     = []
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "bastion_size" {
  description = "Azure VM size for bastion host"
  type        = string
  default     = "Standard_B1ls"
}

variable "vm_size" {
  description = "Azure VM size for zone vms"
  type        = string
  default     = "Standard_B1ls"
}

variable "tags" {
  description = "resource tags"
  type        = map(string)
  default     = {}
}