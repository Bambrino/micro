# Network
resource "yandex_vpc_network" "mynet" {
  name = "mynet"
}

resource "yandex_vpc_subnet" "mysubnet01" {
  name = "subnet01"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.mynet.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}