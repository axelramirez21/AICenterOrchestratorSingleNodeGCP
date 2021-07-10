##################################################################
## GCP GENERAL VALUES
##################################################################
provider "google" {
  credentials = file("technical-account-management-1-0f231056afa6.json")
  # version = "~> 3.74.0"
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file("technical-account-management-1-0f231056afa6.json")
  #version = "~> 3.74.0"
  project = var.project
  region  = var.region
  zone    = var.zone
}

#Random number for the names so multiple deployments dont affect each other
resource "random_id" "deployment_suffix" {
  byte_length = 5
}

##################################################################
## NETWORKING
##################################################################

# Main VPC
resource "google_compute_network" "main" {
  name                    = "${var.deployment_prefix}-vnet-${random_id.deployment_suffix.hex}"
  auto_create_subnetworks = false
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "${var.deployment_prefix}-public-${random_id.deployment_suffix.hex}"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "${var.deployment_prefix}-private-${random_id.deployment_suffix.hex}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "${var.deployment_prefix}-router-${random_id.deployment_suffix.hex}"
  network = google_compute_network.main.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  depends_on = [google_compute_network.main,google_compute_subnetwork.private,google_compute_subnetwork.public]
  name                               = "${var.deployment_prefix}-nat-${random_id.deployment_suffix.hex}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "${var.deployment_prefix}-private-${random_id.deployment_suffix.hex}"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# DNS Private Managed Zone
resource "google_dns_managed_zone" "private-zone" {
  name        = "${var.deployment_prefix}-private-zone-${random_id.deployment_suffix.hex}"
  dns_name    = "${var.doman_dns_name}."
  description = "Private DNS Managed Zone"
  visibility = "private"

  labels = {
    owner = var.environment_owner
    group = var.environment_owner_group
  }

  private_visibility_config {
    networks {
      network_url = google_compute_network.main.id
    }
  }
}

#Record sets
resource "google_dns_record_set" "aicenter-recordset" {
  provider = google-beta
  managed_zone = google_dns_managed_zone.private-zone.name
  name         = "${var.aicenter_dns_name}."
  type         = "A"
  rrdatas      = [google_compute_instance.aicenter.network_interface[0].network_ip]
  ttl          = 86400
}

resource "google_dns_record_set" "orchestrator-recordset" {
  provider = google-beta
  managed_zone = google_dns_managed_zone.private-zone.name
  name         = "${var.orchestrator_dns_name}."
  type         = "A"
  rrdatas      = [google_compute_instance.aicenter-orchestrator.network_interface[0].network_ip]
  ttl          = 86400
}

resource "google_dns_record_set" "db-recordset" {
  provider = google-beta
  depends_on = [google_sql_database_instance.sql-instance]
  managed_zone = google_dns_managed_zone.private-zone.name
  name         = "${var.sqlserver_dns_name}."
  type         = "A"
  rrdatas      = [google_sql_database_instance.sql-instance.private_ip_address]
  ttl          = 86400
}

# Firewall rules
resource "google_compute_firewall" "aicenter-allow-all" {
  name    = "${var.deployment_prefix}-allow-ssh-${random_id.deployment_suffix.hex}"
  network = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
    ports    = ["22","3389","443","80","8800","31443","31390","6443","2379","2380","10250","6783"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "aicenter-allow-icmp" {
  name    = "${var.deployment_prefix}-allow-icmp-${random_id.deployment_suffix.hex}"
  network = google_compute_network.main.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "aicenter-allow-internal" {
  name    = "${var.deployment_prefix}-allow-internal-${random_id.deployment_suffix.hex}"
  network = google_compute_network.main.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.private.ip_cidr_range]
}

##################################################################
## Compute Engine instances
##################################################################

## Compute instance orchestrator
resource "google_compute_instance" "aicenter-orchestrator" {
  depends_on = [google_compute_subnetwork.private,google_sql_database_instance.sql-instance,google_service_networking_connection.private_vpc_connection]
  name         = "${var.deployment_prefix}-orchestrator-${random_id.deployment_suffix.hex}"
  machine_type = var.orchestrator_vm_type
  zone         = var.zone

  labels = {
    owner = var.environment_owner
    group = var.environment_owner_group
  }

  boot_disk {
    initialize_params {
      image = var.orchestrator_image
      size = var.orchestrator_disk_size
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    #network = "default"
    network =  google_compute_network.main.name
    subnetwork = google_compute_subnetwork.private.name

    access_config {
      // Ephemeral IP
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    windows-startup-script-ps1 = data.template_file.init-orchestrator.rendered
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

## Compute instance AI Center
resource "google_compute_instance" "aicenter" {

  depends_on = [google_compute_subnetwork.private,google_sql_database_instance.sql-instance]
  name         = "${var.deployment_prefix}-aicenter-${random_id.deployment_suffix.hex}"
  machine_type = var.aicenter_vm_type
  zone         = var.zone

  labels = {
    owner = var.environment_owner
    group = var.environment_owner_group
  }

  boot_disk {
    initialize_params {
      image = var.aicenter_image
      size = var.aicenter_bootdisk_size
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  attached_disk {
    source = google_compute_disk.seconddisk.name
  }

  attached_disk {
    source = google_compute_disk.thirddisk.name
  }

  guest_accelerator {
    type  = var.aicenter_gpu_type
    count = 1
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  network_interface {
    #network = "default"
    network = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.private.name

    access_config {
      // Ephemeral IP
      network_tier = "PREMIUM"
    }
  }

  metadata_startup_script = data.template_file.aicenter-pre-requisites.rendered

  metadata ={
    ssh-keys = "${var.aicenter_vm_username}:${file("uioadminpublickey.pub")}"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

resource "google_compute_disk" "seconddisk" {
  name  = "${var.deployment_prefix}-disk2-${random_id.deployment_suffix.hex}"
  type  = "pd-ssd"
  zone  = var.zone
  size = var.aicenter_attached_disk1_size
  labels = {
    "owner" = var.environment_owner
    "group" = var.environment_owner_group
  }
}

resource "google_compute_disk" "thirddisk" {
  name  = "${var.deployment_prefix}-disk3-${random_id.deployment_suffix.hex}"
  type  = "pd-ssd"
  zone  = var.zone
  size = var.aicenter_attahced_disk2_size
  labels = {
    "owner" = var.environment_owner
    "group" = var.environment_owner_group
  }
}

##################################################################
## GCP SQL SERVER
##################################################################
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  count = 1
  name          = "${var.deployment_prefix}-private-ip-${random_id.deployment_suffix.hex}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.self_link
  labels = {
    "owner" = var.environment_owner
    "group" = var.environment_owner_group
  }
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on = [google_compute_global_address.private_ip_address]
  provider = google-beta
  count = 1
  network                 = google_compute_network.main.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.0.name]
}


resource "google_sql_database_instance" "sql-instance" {
  depends_on = [google_service_networking_connection.private_vpc_connection]
  provider = google-beta
  name   = "${var.deployment_prefix}-sqlserver-${random_id.deployment_suffix.hex}"
  region = var.region
  database_version = var.sql_version
  root_password    = var.sql_root_pass

  settings {
    tier = var.sql_tier
    user_labels = {
      "owner" = var.environment_owner
      "group" = var.environment_owner_group
    }

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.main.self_link

      authorized_networks {
        name  = "sqlstudio"
        value = "0.0.0.0/0"
      }
    }
  }

  deletion_protection  = "false"
}

resource "google_sql_database" "database" {
  name     = var.orchestrator_databasename
  instance = google_sql_database_instance.sql-instance.name
}

resource "google_sql_user" "sqlserver" {
  depends_on = [google_sql_database_instance.sql-instance]
  name     = var.orchestrator_databaseusername
  password = var.orchestrator_databaseuserpassword
  instance = google_sql_database_instance.sql-instance.name
}