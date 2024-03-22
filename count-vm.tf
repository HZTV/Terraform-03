data "yandex_compute_image" "web" {
  family = var.family_os
}

resource "yandex_compute_instance" "web" {
    count = var.VMS_count
    name = "${var.vm_name}-${count.index+1}" # +1 чтобы отчет начинался не с нуля
    zone = var.web_default_zone
    platform_id = var.standart_platform_id

    depends_on = [yandex_compute_instance.db ]

    resources {
      cores = var.hardware_config_web.web.core
      memory = var.hardware_config_web.web.memory
      core_fraction = var.hardware_config_web.web.core_fraction
    }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.web.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id] # Назначил группу безопасности
  }

  metadata = {
    serial-port-enable = var.ssh_key_for_any_host.serial-port-enable
    ssh-keys           = "ubuntu:${var.ssh_key_for_any_host.ssh-keys}"
  }
}

