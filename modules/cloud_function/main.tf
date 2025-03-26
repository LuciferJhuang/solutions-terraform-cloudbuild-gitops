locals {
  cf_zip_archive_name = "cf-${var.function-name}-${data.archive_file.cf_source_zip.output_sha}.zip"
}

data "archive_file" "cf_source_zip" {
  type        = "zip"
  source_dir  = "../../functions/${var.function-name}"
  output_path = "${path.module}/tmp/${var.function-name}.zip"
}

resource "google_storage_bucket_object" "cf_source_zip" {
  name          = local.cf_zip_archive_name
  source        = data.archive_file.cf_source_zip.output_path
  content_type  = "application/zip"
  bucket        = "${var.project}-source-code"
}

resource "google_cloudfunctions2_function" "function" {
  project     = var.project
  location    = var.region
  name        = var.function-name
  description = var.function-desc
  
  build_config {
    runtime     = "python39"
    entry_point = var.entry-point
    source {
      storage_source {
        bucket = "${var.project}-source-code"
        object = google_storage_bucket_object.cf_source_zip.name
      }
    }
  }
  
  service_config {
    service_account_email = google_service_account.service_account.email
    environment_variables = var.env-vars == null ? null : var.env-vars

    ingress_settings      = var.triggers == null ? "ALLOW_ALL" : "ALLOW_INTERNAL_ONLY" 

    dynamic "secret_environment_variables" {
      for_each = var.secrets == null ? [] : var.secrets
      content {
          project_id  = var.project
          key         = secret_environment_variables.value.key
          secret      = secret_environment_variables.value.id
          version     = "latest"
      }
    }
  }

  event_trigger {
    event_type    = var.triggers[0].event_type
    pubsub_topic  = var.triggers[0].event_type == "google.cloud.pubsub.topic.v1.messagePublished" ? var.triggers[0].resource : null
    dynamic "event_filters" {
      for_each = var.triggers[0].event_type == "google.cloud.storage.object.v1.finalized" ? var.triggers : []
      content {
        attribute = "bucket"
        value     = event_filters.value.resource
      }
    }
  }
}

resource "google_service_account" "service_account" {
  account_id   = "sa-${var.function-name}"
  display_name = "sa-${var.function-name}"
}
