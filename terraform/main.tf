## NETWORK ##

resource "google_compute_network" "jenkins_network" {
  name                    = "jenkins-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "jenkins_subnetwork" {
  name          = "jenkins-subnet"
  ip_cidr_range = "10.0.0.0/27"
  network       = google_compute_network.jenkins_network.id
}

locals {

  # SSH Setup
  ssh_keys = (
    var.ssh_keys != null ?
    var.ssh_keys :
    { "ubuntu" : file("~/.ssh/id_rsa.pub") }
  )
}


## FIREWALL ##

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.jenkins_network.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.jenkins_network.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.jenkins_network.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.jenkins_network.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "all"
  }

  source_ranges      = ["10.0.0.0/24"]
  destination_ranges = ["10.0.0.0/24"]
}


## INSTANCE ##

resource "google_compute_address" "jenkins_ip" {
  name = "${var.hostname}-ip"
}

resource "google_compute_instance" "jenkins_instance" {
  name         = var.hostname
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.jenkins_subnetwork.name

    access_config {
      nat_ip = google_compute_address.jenkins_ip.address
    }
  }

  metadata = {
    ssh-keys = join(" ", [for key, value in local.ssh_keys : format("%s:%s", key, value)])
  }

  zone = var.zone
}


## WRITE HOST IP ##

resource "local_file" "ansible_inventory" {
  depends_on = [google_compute_instance.jenkins_instance]
  content = templatefile(
    "../hosts.ini",
    {
      host = google_compute_address.jenkins_ip.address
    }
  )
  filename = "../inventory.ini"
}
