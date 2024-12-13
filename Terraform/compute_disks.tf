resource "yandex_compute_disk" "disk-web-1" {
  name     = "disk-web-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}

resource "yandex_compute_disk" "disk-web-2" {
  name     = "disk-web-2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}

resource "yandex_compute_disk" "disk-bastion" {
  name     = "disk-bastion"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}

resource "yandex_compute_disk" "disk-zabbix" {
  name     = "disk-zabbix"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}

resource "yandex_compute_disk" "disk-elasticsearch" {
  name     = "disk-elasticsearch"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}

resource "yandex_compute_disk" "disk-kibana" {
  name     = "disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd8svvs3unvqn83thrdk"
  size     = 10
  
}
