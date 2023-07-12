resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "secret-version"

  labels = {
    label = "my-label"
  }

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret-basic.id

  secret_data = file("${path.module}/config.yaml")
}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "asia-northeast1"
  ingress  = "INGRESS_TRAFFIC_ALL"
  launch_stage = "BETA"
  provider = google-beta

  template {
    containers {
      name  = "api"
      image = "asia-northeast1-docker.pkg.dev/test-satoken/java-example/api:latest"
      ports {
        container_port = 8080
      }
    }
    containers {
      name  = "otel-collector"
      image = "otel/opentelemetry-collector-contrib"
      volume_mounts {
        name       = "config"
        mount_path = "/etc/otel"
      }

    }
    volumes {
      name = "config"
      secret {
        secret = google_secret_manager_secret_version.secret-version-basic.secret
        items {
          path = "config.yaml"
          version = "latest"
          mode = 0
        }
      }
    }
  }
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}