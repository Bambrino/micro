resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 50"
  }

  depends_on = [
    local_file.hosts
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/mykubecl/hosts.yaml  --private-key=${var.ssh_private_key} --become --become-user=root cluster.yml"
    working_dir = "/home/vvk/dz/micro/14.2/files/kuberspray"
  }

  depends_on = [
    null_resource.wait
  ]
}


