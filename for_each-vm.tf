
data "yandex_compute_image" "db" {
  family = var.family_os
}

resource "yandex_compute_instance" "db" {
  for_each = tomap({for i in var.each_vm : i.vm_name => i})
  name = each.value.vm_name
  # Ссылка https://github.com/hashicorp/vscode-terraform/issues/1693
  zone = var.web_default_zone
  platform_id = var.standart_platform_id

    resources {
      cores = each.value.cpu
      memory = each.value.ram
      core_fraction = each.value.core_fraction
    }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db.image_id
      type     = each.value.type_storage
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = each.value.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = each.value.nat
  }

  metadata = {
    serial-port-enable = var.ssh_key_for_any_host.serial-port-enable
    ssh-keys           = "ubuntu:${local.KEY}" # Считываем ключ из файла, а не переменной
  }
}


