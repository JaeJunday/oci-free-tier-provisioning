variable "region" {
  description = "OCI region. Always Free compute and block volumes must be created in the tenancy home region."
  type        = string
  default     = "ap-chuncheon-1"
}

variable "compartment_id" {
  description = "OCI compartment OCID where resources will be created"
  type        = string

  validation {
    condition     = startswith(var.compartment_id, "ocid1.compartment.") || startswith(var.compartment_id, "ocid1.tenancy.")
    error_message = "compartment_id must be an OCI compartment OCID, or the tenancy OCID when using the root compartment."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for ubuntu user access"
  type        = string

  validation {
    condition     = startswith(var.ssh_public_key, "ssh-ed25519 ") || startswith(var.ssh_public_key, "ssh-rsa ") || startswith(var.ssh_public_key, "ecdsa-sha2-")
    error_message = "ssh_public_key must be a valid OpenSSH public key."
  }
}

variable "instance_display_name" {
  description = "Display name for the compute instance and related resources"
  type        = string
  default     = "free-tier-host"
}

variable "hostname_label" {
  description = "DNS hostname label for the instance VNIC"
  type        = string
  default     = "freehost"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "free"
}

variable "vcn_cidr_block" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_cidr_block, 0))
    error_message = "vcn_cidr_block must be a valid CIDR block."
  }
}

variable "subnet_cidr_block" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "subnet_cidr_block must be a valid CIDR block."
  }
}

variable "instance_shape" {
  description = "Shape for compute instance. This provisioning is restricted to the Always Free Ampere A1 shape."
  type        = string
  default     = "VM.Standard.A1.Flex"

  validation {
    condition     = var.instance_shape == "VM.Standard.A1.Flex"
    error_message = "Only VM.Standard.A1.Flex is allowed by this Free Tier guardrail."
  }
}

variable "instance_ocpus" {
  description = "Number of OCPUs (Always Free max: 4)"
  type        = number
  default     = 4

  validation {
    condition     = var.instance_ocpus > 0 && var.instance_ocpus <= 4
    error_message = "instance_ocpus must be greater than 0 and no more than the Always Free A1 total of 4 OCPUs."
  }
}

variable "instance_memory_in_gbs" {
  description = "Memory in GBs (Always Free max: 24)"
  type        = number
  default     = 24

  validation {
    condition     = var.instance_memory_in_gbs > 0 && var.instance_memory_in_gbs <= 24
    error_message = "instance_memory_in_gbs must be greater than 0 and no more than the Always Free A1 total of 24 GB."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB. Always Free block storage is shared across boot and block volumes."
  type        = number
  default     = 100

  validation {
    condition     = var.boot_volume_size_in_gbs >= 47 && var.boot_volume_size_in_gbs <= 200
    error_message = "boot_volume_size_in_gbs must be between OCI's 47 GB minimum and the 200 GB Always Free block storage total."
  }
}

variable "availability_domain_index" {
  description = "Zero-based availability domain index to use"
  type        = number
  default     = 0

  validation {
    condition     = var.availability_domain_index >= 0
    error_message = "availability_domain_index must be zero or greater."
  }
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach SSH before private networking is configured. Use your public IP with /32 when possible."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_ingress_cidr, 0))
    error_message = "ssh_ingress_cidr must be a valid CIDR block."
  }
}

variable "workspace_path" {
  description = "Directory created on the instance for user workloads"
  type        = string
  default     = "/opt/workspace"
}
