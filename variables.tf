variable "regions" {
  description = "List of regions to deploy"
  type        = list
  default     = []
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "tags" {
  description = "resource tags"
  type        = map(string)
  default     = {}
}