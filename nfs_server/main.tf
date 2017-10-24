provider "openstack" {
}

resource "openstack_networking_network_v2" "terraform" {
  name = "terraform"
  admin_state_up = "true"
}

resource "openstack_compute_keypair_v2" "terraform" {
  name = "SSH keypair for Terraform instances"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_subnet_v2" "terraform" {
  name = "terraform"
  network_id = "${openstack_networking_network_v2.terraform.id}"
  cidr = "172.16.1.0/24"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["141.142.2.2","141.142.230.144"]
}

resource "openstack_networking_router_v2" "terraform" {
  name = "terraform"
  admin_state_up = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = "${openstack_networking_router_v2.terraform.id}"
  subnet_id = "${openstack_networking_subnet_v2.terraform.id}"
}

resource "openstack_compute_floatingip_v2" "terraform" {
  depends_on = ["openstack_networking_router_interface_v2.terraform"]
  pool = "${var.pool}"
}

resource "openstack_compute_secgroup_v2" "terraform" {
  name = "terraform"
  description = "Security group for the Terraform instances"
  rule {
    from_port = 111
    to_port = 111
    ip_protocol = "tcp"
    cidr = "141.142.0.0/16"
  }
  rule {
    from_port = 2049
    to_port = 2049
    ip_protocol = "tcp"
    cidr = "141.142.0.0/16"
  }
  rule {
    from_port = 4045
    to_port = 4045
    ip_protocol = "tcp"
    cidr = "141.142.0.0/16"
  }
  rule {
    from_port = 32767
    to_port = 32767
    ip_protocol = "tcp"
    cidr = "141.142.0.0/16"
  }
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_blockstorage_volume_v2" "terraform" {
  name = "terraform"
  description = "Terraform test volume"
  size = "${var.nfs_size}"
}

resource "openstack_compute_instance_v2" "terraform" {
  name = "terraform"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  key_pair = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = [ "${openstack_compute_secgroup_v2.terraform.name}" ]
  floating_ip = "${openstack_compute_floatingip_v2.terraform.address}"
  volume {
    volume_id = "${openstack_blockstorage_volume_v2.terraform.id}"
  }
  network {
    uuid = "${openstack_networking_network_v2.terraform.id}"
  }

  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
    connection {
      user = "${var.ssh_user_name}"
      key_file = "${var.ssh_key_file}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh ${var.nfs_name}"
    ]
    connection {
      user = "${var.ssh_user_name}"
      key_file = "${var.ssh_key_file}"
    }
  }
}
