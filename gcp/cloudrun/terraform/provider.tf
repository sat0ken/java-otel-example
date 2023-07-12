terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.73.0"
    }
  }
}

provider "google" {
  project = "test-satoken"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

provider "google-beta" {
  project = "test-satoken"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}