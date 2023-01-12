terraform {
 required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.48.0"
    }
  }
 
 backend "gcs" {
   bucket  = "terraform-teste"
   prefix  = "terraform/state"
 }
}