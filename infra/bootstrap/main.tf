provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  use_repo_ids            = var.github_owner_id != null && var.github_repo_id != null
  repo_full_name          = "${var.github_owner}/${var.github_repo}"
  wif_attribute_condition = local.use_repo_ids ? "assertion.repository_owner_id == \"${var.github_owner_id}\" && assertion.repository_id == \"${var.github_repo_id}\"" : "assertion.repository_owner == \"${var.github_owner}\" && assertion.repository == \"${local.repo_full_name}\""
  wif_principal_attr      = local.use_repo_ids ? "attribute.repository_id/${var.github_repo_id}" : "attribute.repository/${local.repo_full_name}"
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  public_access_prevention = "enforced"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "OIDC pool for GitHub Actions"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.actor"               = "assertion.actor"
    "attribute.repository"          = "assertion.repository"
    "attribute.repository_owner"    = "assertion.repository_owner"
    "attribute.repository_id"       = "assertion.repository_id"
    "attribute.repository_owner_id" = "assertion.repository_owner_id"
    "attribute.ref"                 = "assertion.ref"
  }

  attribute_condition = local.wif_attribute_condition
}

resource "google_service_account" "terraform_deployer" {
  account_id   = var.terraform_sa_id
  display_name = var.terraform_sa_display_name
}

resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.terraform_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/${local.wif_principal_attr}"
}

resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = var.terraform_sa_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform_deployer.email}"
}
