resource "yandex_compute_instance" "worker04" {
  name                      = "worker04"
  zone                      = "${var.YC_ZONE}"
  hostname                  = "worker04.kube.local"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_2004}"
      name        = "root-worker04"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.mysubnet01.id}"
    nat        = true
    ip_address = "192.168.101.23"
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}