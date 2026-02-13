variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "site_domains" {
  type        = list(string)
  description = "Domains for the managed SSL certificate (apex and optional www)."
  default     = []
}
