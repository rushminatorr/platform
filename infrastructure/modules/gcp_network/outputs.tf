# VPC
output "network_name" {
    description = "The name of the VPC being created"
    value       = "${module.vpc.network_name}"
}

output "network_self_link" {
    description = "The URI of the VPC being created"
    value       = "${module.vpc.network_self_link}"
}

output "routes" {
    description = "The routes associated with this VPC"
    value       = "${module.vpc.routes}"
}

output "subnets_ips" {
    description = "The IPs and CIDRs of the subnets being created"
    value       = "${module.vpc.subnets_ips}"
}

output "subnets_names" {
    description = "The names of the subnets being created"
    value       = "${module.vpc.subnets_names}"
}

output "subnets_secondary_ranges" {
    description = "The secondary ranges associated with these subnets"
    value       = "${module.vpc.subnets_secondary_ranges}"
}

output "subnets_self_links" {
    description = "The self-links of subnets being created"
    value       = "${module.vpc.subnets_self_links}"
}