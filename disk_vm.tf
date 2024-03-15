
data "yandex_compute_image" "storage" {
  family = var.family_os
}

# Создаем три диска
resource "yandex_compute_disk" "vhd" {
  count = var.VHD_conf.count
  name = "${var.VHD_conf.name}-${count.index +1}"
  type = var.VHD_conf.type
  zone = var.default_zone
  size = var.VHD_conf.size
  block_size = var.VHD_conf.block_size
}




# Создание доп.вм чтобы подключить доп. диски
resource "yandex_compute_instance" "storage" {
  name = var.name_storage
  zone = var.web_default_zone
    platform_id = var.standart_platform_id

    resources {
      cores = var.hardware_config_web.web.core
      memory = var.hardware_config_web.web.memory
      core_fraction = var.hardware_config_web.web.core_fraction
    }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.storage.image_id
    }
  }
# Подкл. доп. дисков
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.vhd
    content {
      disk_id= secondary_disk.value.id
      
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = var.ssh_key_for_any_host.serial-port-enable
    ssh-keys           = "ubuntu:${var.ssh_key_for_any_host.ssh-keys}"
  }
}