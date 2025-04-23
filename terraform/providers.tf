terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.30.0"
    }
  }
}

provider "google" {
  project = var.project_name
  region  = var.region
}
