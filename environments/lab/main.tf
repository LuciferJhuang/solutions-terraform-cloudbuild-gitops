terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {

  project = "e6j2-training"
  region  = "asia-east1"
  zone    = "asia-east1-a"
}

resource "google_compute_instance" "terraform" {
  name         = "terraform"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}

module "im-workspace" {
 source = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
 version = "~> 7.0"
 project_id = "e6j2-training"
 deployment_id = "cloudbuild-terraform-lab"
 im_deployment_repo_uri = "https://github.com/LuciferJhuang/solutions-terraform-cloudbuild-gitops"
 github_personal_access_token = "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"
}
