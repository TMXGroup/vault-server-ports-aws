terraform {
  required_version = ">= 0.11.6"
}

resource "aws_security_group" "vault_server" {
  count = "${var.create ? 1 : 0}"

  name_prefix = "${var.name}-"
  description = "Security Group for ${var.name} Vault"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

# Default listen port for UI and API connectivity.
resource "aws_security_group_rule" "vault_client_traffic" {
  count = "${var.create ? 1 : 0}"

  security_group_id         = "${aws_security_group.vault_server.id}"
  type                      = "ingress"
  protocol                  = "tcp"
  from_port                 = 8200
  to_port                   = 8200
  source_security_group_id  = "${var.consul_sg_group}"
  description               = "Consul cluster SG"
}

# Default listen port for UI and API connectivity.
resource "aws_security_group_rule" "vault_client_traffic_internal" {
  count = "${var.create ? 1 : 0}"

  security_group_id         = "${aws_security_group.vault_server.id}"
  type                      = "ingress"
  protocol                  = "tcp"
  from_port                 = 8200
  to_port                   = 8200
  source_security_group_id  = "${aws_security_group.vault_server.id}"
  description               = "Vault internal cluster SG"
}

# Listen port for vault load balancer
resource "aws_security_group_rule" "vault_client_traffic_lb" {
  count = "${var.create ? 1 : 0}"

  security_group_id         = "${aws_security_group.vault_server.id}"
  type                      = "ingress"
  protocol                  = "tcp"
  from_port                 = 8200
  to_port                   = 8200
  source_security_group_id  = "${var.vault_lb_sg_group}"
  description               = "Vault LB SG"
}

# Default listen port for server to server requests within a cluster. Also required for cluster to cluster replication traffic.
resource "aws_security_group_rule" "vault_cluster_traffic" {
  count = "${var.create ? 1 : 0}"

  security_group_id         = "${aws_security_group.vault_server.id}"
  type                      = "ingress"
  protocol                  = "tcp"
  from_port                 = 8201
  to_port                   = 8201
  source_security_group_id  = "${var.consul_sg_group}"
  description               = "Consul cluster SG"
}

resource "aws_security_group_rule" "vault_cluster_traffic_internal" {
  count = "${var.create ? 1 : 0}"

  security_group_id         = "${aws_security_group.vault_server.id}"
  type                      = "ingress"
  protocol                  = "tcp"
  from_port                 = 8201
  to_port                   = 8201
  source_security_group_id  = "${aws_security_group.vault_server.id}"
  description               = "Vault internal cluster SG"
}

# All outbound traffic - TCP.
resource "aws_security_group_rule" "outbound_tcp" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${aws_security_group.vault_server.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}
