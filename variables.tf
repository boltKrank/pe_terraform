variable "pe_installer_url" {
  description = "Location of the Puppet Enterprise installer"
  default     = "https://s3.amazonaws.com/pe-builds/released/2017.3.2/puppet-enterprise-2017.3.2-el-7-x86_64.tar.gz"
}

variable "pe_conf" {
  description = "The content of pe.conf"
  default     = <<EOF
{
  "console_admin_password": "puppetlabs"
}
EOF
}
