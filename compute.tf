resource "openstack_compute_instance_v2" "webserver" {
  name            = "webserver"
  key_pair        = openstack_compute_keypair_v2.keypair.id
  security_groups = ["default"]
  flavor_name     = "gp1.lightspeed"
  image_name      = "Ubuntu-20.04"
  user_data       = "${path.module}/setup.sh"
  network {
    name = "public"
  }
}

resource "openstack_compute_volume_attach_v2" "webserver" {
  instance_id = openstack_compute_instance_v2.webserver.id
  volume_id   = openstack_blockstorage_volume_v2.web_data.id
}