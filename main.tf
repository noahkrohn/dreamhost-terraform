provider "aws" {
  region = var.region
}

provider "openstack" {
  user_name   = var.user_name
  password    = var.password
  tenant_name = var.tenant_name
  tenant_id   = var.tenant_id
  auth_url    = var.auth_url
}