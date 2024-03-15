resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
  depends_on = [yandex_vpc_network.db ]
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
  depends_on = [yandex_vpc_subnet.db ]
}

#####################################


resource "yandex_vpc_network" "db" {
  name = var.vpc_name_db
}

resource "yandex_vpc_subnet" "db" {
  name           = var.vpc_name_db
  zone           = var.default_zone
  network_id     = yandex_vpc_network.db.id
  v4_cidr_blocks = var.default_cidr
}


# Блок с ansible
resource "local_file" "hosts_for" {
  depends_on = [ yandex_compute_instance.web,
  yandex_compute_instance.db,
  yandex_compute_instance.storage ]
  
content =  <<-EOT

  %{if length(yandex_compute_instance.web) > 0}
  [webservers]
  %{endif}
  %{for i in yandex_compute_instance.web }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
  %{endfor}

  %{if length(yandex_compute_instance.db) > 0}
  [database]
  %{endif}
  %{for i in yandex_compute_instance.db }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
  %{endfor}

  %{if length(yandex_compute_instance.storage) >0}
  [storage] 
  %{endif}
  %{for i in [yandex_compute_instance.storage]}
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
  %{endfor }
  EOT
  filename = "${abspath(path.module)}/for.cfg"

}
