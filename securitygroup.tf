data "openstack_networking_secgroup_v2" "default" {
  name              = "default"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  description       = "Only allow ssh from my IP"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.remote_ip_prefix
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  description       = "Inbound HTTP traffic"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  description       = "Inbound HTTPS traffic"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "egress_tcp" {
  direction         = "egress"
  description       = "Allow list for outbound TCP"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "egress_udp" {
  direction         = "egress"
  description       = "Allow list for outbound udp"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "udp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "egress_icmp" {
  direction         = "egress"
  description       = "Allow list for outbound icmp"
  ethertype         = "IPv4"
  security_group_id = data.openstack_networking_secgroup_v2.default.id
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}