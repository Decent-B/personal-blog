variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "state_bucket_name" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_owner_id" {
  type    = string
  default = null
}

variable "github_repo_id" {
  type    = string
  default = null
}

variable "wif_pool_id" {
  type    = string
  default = "github"
}

variable "wif_provider_id" {
  type    = string
  default = "github"
}

variable "terraform_sa_id" {
  type    = string
  default = "terraform-deployer"
}

variable "terraform_sa_display_name" {
  type    = string
  default = "Terraform Deployer"
}

variable "terraform_sa_roles" {
  type = set(string)
  default = [
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/compute.viewer"
  ]
}
