output "state_bucket_name" {
  value = google_storage_bucket.tf_state.name
}

output "terraform_service_account_email" {
  value = google_service_account.terraform_deployer.email
}

output "wif_pool_name" {
  value = google_iam_workload_identity_pool.github.name
}

output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github.name
}
