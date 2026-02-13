output "site_bucket_name" {
  value = google_storage_bucket.site.name
}

output "lb_ip" {
  value = google_compute_global_address.site.address
}

output "managed_cert_name" {
  value = google_compute_managed_ssl_certificate.site.name
}
