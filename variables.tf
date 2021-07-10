variable "project" {
  description = "The name of the GCP project"
}

variable "region" {
  description = "Name of the GCP region"
}

variable "zone" {
  description = "Name of the Availability zone"
}

variable "gcp_credentials" {
  description = "JSON File"
}

variable "deployment_prefix" {
  description = "Environment Prefix"
}

variable "environment_owner" {
  description = "Your email address for labels"
}

variable "environment_owner_group" {
  description = "Environment Owner group. Ej. TAM"
}

variable "doman_dns_name" {
  description = "DNS domain name. Ej. rpauniverse.com"
}

variable "aicenter_dns_name" {
  description = "AI Center DNS record. Ej. aicenter.rpauniverse.com"
}

variable "orchestrator_dns_name" {
  description = "Orchestrator DNS domain name. Ej. orchestrator.rpauniverse.com"
}

variable "sqlserver_dns_name" {
  description = "Orchestrator DNS domain name. Ej. db.rpauniverse.com"
}

variable "orchestrator_vm_type" {
  description = "VM type. Ej. n2-standard-4"
}

variable "orchestrator_image" {
  description = "VM image for orchestrator server, needs to be windows based. Ej. windows-server-2019-dc-v20200114"
}

variable "set_local_adminpass" {
  description = "Set local admin password."
}

variable "admin_password" {
  description = "Local windows administrator password. If variable 'set_local_adminpass' is 'yes'."
}

## Set Orchestrator local account role : localadmin or localuser
variable "orchestrator_local_account_role" {
  description = "Orchestrator local accout role : localadmin or localuser"
}

#Orchestrator VM username
variable "vm_username" {
  description = "Orchestrator windows account to be created"
}

#Orchestrator VM password
variable "vm_password" {
  description = "Password of the windows orchestrator account"
}

#orchestrator version
variable "orchestrator_version" {
  description = " Orchestrator version to be installed ej. 19.10.15"
}

#orchestrator passphrase
variable "orchestrator_passphrase" {
  description = "passphrase for the orchestrator instance"
}

#orchestrator databaseServerName
variable "orchestrator_databaseservername" {
  description = "Database server name for the SQL server"
}

#orchestrator databaseName
variable "orchestrator_databasename" {
  description = "Data"
}

#orchestrator databaseuserName
variable "orchestrator_databaseusername" {
  description = "SQL database username"
}

#orchestrator databaseUserPassword
variable "orchestrator_databaseuserpassword" {
  description = "SQL server password"
}

#orchestrator orchestratoradminpassword
variable "orchestrator_orchestratoradminpassword" {
  description = "Orchestrator administrator password"
}

variable "orchestrator_disk_size" {
  description = "size in gigabites"
}

variable "aicenter_vm_type" {
  description = "Machine type for the Linux box. Ej. n1-standard-16"
}

variable "aicenter_image" {
  description = "Machine Linux image for AICenter Ej. ubuntu-os-pro-cloud/ubuntu-pro-1804-bionic-v20210623"
}

variable "aicenter_bootdisk_size" {
  description = "Disk size in GB"
}

variable "aicenter_gpu_type" {
  description = "GPU type to attach to the linux host. Ej. nvidia-tesla-t4"
}

variable "aicenter_attached_disk1_size" {
  description = "Attached disk size in GB"
}

variable "aicenter_attahced_disk2_size" {
  description = "attached disk size in GB"
}

variable "aicenter_vm_username" {
  description = "Linux Username"
}

variable "sql_root_pass" {
  description = "Root password for SQLServer; Required to create instance"
}

variable "sql_version"{
  description = "Version for the Identity DB"
}

variable "sql_tier"{
  description = "Tier for SQL Server"
}

variable "identity_server_db_name"{
  description = "Database name for the Identity Server"
}

variable "identity_db_server_name"{
  description = "Server name for Identity Server"
}

variable "identity_server_authentication_mode"{
  description = "Server name for Identity Server"
}

variable "identity_server_db_user"{
  description = "User for the Identity Database"
}

variable "identity_server_db_password"{
  description = "Password for the Identity DB"
}

variable "certificate_dns_names"{
  description = "DNS names to be included on the certificate"
}