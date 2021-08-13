resource "openstack_networking_floatingip_v2" "webserver" {
  pool  = "public"
}