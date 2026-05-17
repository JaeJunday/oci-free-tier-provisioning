output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = oci_core_instance.agent_host.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.agent_host.private_ip
}

output "instance_id" {
  description = "OCID of the instance"
  value       = oci_core_instance.agent_host.id
}

output "instance_state" {
  description = "Current state of the instance"
  value       = oci_core_instance.agent_host.state
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.agent_vcn.id
}

output "subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.agent_subnet.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ubuntu@${oci_core_instance.agent_host.public_ip}"
}
