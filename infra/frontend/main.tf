provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  site_bucket_name = "${var.project_id}-site"
}

resource "google_storage_bucket" "site" {
  name                        = local.site_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "site" {
  name        = "${var.project_id}-site-backend"
  bucket_name = google_storage_bucket.site.name
  enable_cdn  = true

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"
  }
}

resource "google_compute_url_map" "site" {
  name            = "${var.project_id}-site-url-map"
  default_service = google_compute_backend_bucket.site.id
}

resource "google_compute_url_map" "site_redirect" {
  name = "${var.project_id}-site-redirect"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "site" {
  name    = "${var.project_id}-site-http-proxy"
  url_map = google_compute_url_map.site_redirect.id
}

resource "google_compute_global_address" "site" {
  name = "${var.project_id}-site-ip"
}

resource "google_compute_global_forwarding_rule" "site" {
  name       = "${var.project_id}-site-http"
  ip_address = google_compute_global_address.site.address
  port_range = "80"
  target     = google_compute_target_http_proxy.site.id
}

resource "google_compute_managed_ssl_certificate" "site" {
  name = "${var.project_id}-site-cert"

  managed {
    domains = var.site_domains
  }
}

resource "google_compute_target_https_proxy" "site" {
  name             = "${var.project_id}-site-https-proxy"
  url_map          = google_compute_url_map.site.id
  ssl_certificates = [google_compute_managed_ssl_certificate.site.id]
}

resource "google_compute_global_forwarding_rule" "site_https" {
  name       = "${var.project_id}-site-https"
  ip_address = google_compute_global_address.site.address
  port_range = "443"
  target     = google_compute_target_https_proxy.site.id
}
