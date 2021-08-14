resource "openstack_blockstorage_volume_v2" "web_data" {
  name        = "webdata"
  description = "map to /var/www"
  size        = 10
}
