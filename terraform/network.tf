# VCN (Virtual Cloud Network)
resource "oci_core_vcn" "agent_vcn" {
  compartment_id = var.compartment_id
  display_name   = "${var.instance_display_name}-vcn"
  cidr_blocks    = [var.vcn_cidr_block]
  dns_label      = var.vcn_dns_label
}

# Internet Gateway
resource "oci_core_internet_gateway" "agent_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.agent_vcn.id
  display_name   = "${var.instance_display_name}-igw"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "agent_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.agent_vcn.id
  display_name   = "${var.instance_display_name}-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.agent_igw.id
    description       = "Route to Internet Gateway"
  }
}

# Security List
resource "oci_core_security_list" "agent_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.agent_vcn.id
  display_name   = "${var.instance_display_name}-security-list"

  # Egress Rules (Outbound)
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  # Ingress Rules (Inbound)
  # SSH (for initial setup and management)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.ssh_ingress_cidr
    description = "SSH"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Tailscale UDP (for VPN connectivity)
  ingress_security_rules {
    protocol    = "17" # UDP
    source      = "0.0.0.0/0"
    description = "Tailscale"
    udp_options {
      min = 41641
      max = 41641
    }
  }

  # ICMP (Ping for network diagnostics)
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "ICMP Ping"
  }
}

# Public Subnet
resource "oci_core_subnet" "agent_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.agent_vcn.id
  cidr_block        = var.subnet_cidr_block
  display_name      = "${var.instance_display_name}-public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.agent_route_table.id
  security_list_ids = [oci_core_security_list.agent_security_list.id]
}
