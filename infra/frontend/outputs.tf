output "site_bucket_name" {
  value = google_storage_bucket.site.name
}

output "lb_ip" {
  value = google_compute_global_address.site.address
}
