provider "openstack" {
  user_name = "simon.anderson"
  tenant_name = "simon.anderson"
  tenant_id = "b00090c0b8c345399f0a5d378b585e89"
  domain_name = "Default"
  password = "yukako81isamu13kiera15"
  auth_url = "https://slice-pdx1-prod.ops.puppetlabs.net:5000/v3"
  region = "pdx1"
}

resource "openstack_compute_instance_v2" "basic_instance" {
  name            = "basic_instance"
  image_name      = "centos_7_x86_64"
  flavor_name     = "m1.medium"
  key_pair        = "slice"
  security_groups = ["sg0"]

}

resource "openstack_networking_floatingip_v2" "basic_float_ip" {
  pool  = "ext-net-pdx1-opdx1"
}

resource "openstack_compute_floatingip_associate_v2" "basic_float_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.basic_float_ip.address}"
  instance_id = "${openstack_compute_instance_v2.basic_instance.id}"
  fixed_ip    = "${openstack_compute_instance_v2.basic_instance.access_ip_v4}"


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "${openstack_networking_floatingip_v2.basic_float_ip.address}"
      user        = "centos"
      password    = ""
      private_key = "${file("terra")}"
      agent = false
    }

    inline = [
        # Download the Puppet Enterprise installer
        "while : ; do",
        "  until curl --max-time 300 -o pe-installer.tar.gz \"${var.pe_installer_url}\"; do sleep 1; done",
        "  tar -xzf pe-installer.tar.gz && break",
        "done",

        # Install Puppet enterprise
        "cat > pe.conf <<-EOF",
        "${var.pe_conf}",
        "EOF",
        "sudo ./puppet-enterprise-*-el-7-x86_64/puppet-enterprise-installer -c pe.conf",

        # Run Puppet a few times to finalise installation
        "until sudo /opt/puppetlabs/bin/puppet agent -t; do sleep 1; done",
    ]
  }

}
