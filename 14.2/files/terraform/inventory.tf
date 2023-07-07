resource "local_file" "hosts" {
  content = <<-DOC
    # Ansible inventory containing variable values from Terraform.
    # Generated by Terraform.

    
    all:
      hosts:
        master01:
          ansible_host: ${yandex_compute_instance.master01.network_interface.0.nat_ip_address}
          ip: ${yandex_compute_instance.master01.network_interface.0.ip_address}
          access_ip: ${yandex_compute_instance.master01.network_interface.0.ip_address}
          ansible_ssh_user: "ubuntu"
        worker01:
          ansible_host: ${yandex_compute_instance.worker01.network_interface.0.nat_ip_address}
          ip: ${yandex_compute_instance.worker01.network_interface.0.ip_address}
          access_ip: ${yandex_compute_instance.worker01.network_interface.0.ip_address}
          ansible_ssh_user: "ubuntu"
        worker02:
          ansible_host: ${yandex_compute_instance.worker02.network_interface.0.nat_ip_address}
          ip: ${yandex_compute_instance.worker02.network_interface.0.ip_address}
          access_ip: ${yandex_compute_instance.worker02.network_interface.0.ip_address}
          ansible_ssh_user: "ubuntu"
        worker03:
          ansible_host: ${yandex_compute_instance.worker03.network_interface.0.nat_ip_address}
          ip: ${yandex_compute_instance.worker03.network_interface.0.ip_address}
          access_ip: ${yandex_compute_instance.worker03.network_interface.0.ip_address}
          ansible_ssh_user: "ubuntu"
        worker04:
          ansible_host: ${yandex_compute_instance.worker04.network_interface.0.nat_ip_address}
          ip: ${yandex_compute_instance.worker04.network_interface.0.ip_address}
          access_ip: ${yandex_compute_instance.worker04.network_interface.0.ip_address}
          ansible_ssh_user: "ubuntu"
      children:
        kube_control_plane:
          hosts:
            master01:
        kube_node:
          hosts:
            worker01:
            worker02:
            worker03:
            worker04:
        etcd:
          hosts:
            master01:
        k8s_cluster:
          children:
            kube_control_plane:
            kube_node:
        calico_rr:
          hosts: {}
    
    DOC
  filename = var.hosts_file

  depends_on = [
    yandex_compute_instance.master01,
    yandex_compute_instance.worker01,
    yandex_compute_instance.worker02,
    yandex_compute_instance.worker03,
    yandex_compute_instance.worker04
  ]
}
