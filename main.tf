
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-wordpress-teste"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "subnet-wordpress-teste"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "http" {
  name    = "firewall-http"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["firewall-http"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "default" {
  name         = "vm-wordpress"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh",
                  "firewall-http",                    
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20220213"
    }
  }

  metadata_startup_script = "${file("script.sh")}"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}