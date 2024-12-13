terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "**************************"
  cloud_id  = "**************************"
  folder_id = "***************************"

}

#----------------- Webservers -----------------------------

resource "yandex_compute_instance" "web-1" {
  name                      = "web-1"
  hostname                  = "web-1"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-web-1.id}"
    }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-web-1.id
    security_group_ids = [yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.10.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

resource "yandex_compute_instance" "web-2" {
  name                      = "web-2"
  hostname                  = "web-2"
  zone                      = "ru-central1-b"
  allow_stopping_for_update = true
  platform_id               = "standard-v1" 

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-web-2.id}"
    }
    
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-web-2.id
    security_group_ids = [yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.20.20"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

#----------------- Bastion -----------------------------

resource "yandex_compute_instance" "bastion" {
  name                      = "bastion"
  hostname                  = "bastion"
  zone                      = "ru-central1-b" #c
  allow_stopping_for_update = true
  platform_id               = "standard-v1" 

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-bastion.id}"
    }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion-rules.id, yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.40.40"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


#----------------- Zabbix -----------------------------

resource "yandex_compute_instance" "zabbix" {
  name                      = "zabbix"
  hostname                  = "zabbix"
  zone                      = "ru-central1-b" #c
  allow_stopping_for_update = true
  platform_id               = "standard-v1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-zabbix.id}"
    }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix-rules.id, yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.40.41"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

#----------------- Elasticsearch -----------------------------

resource "yandex_compute_instance" "elasticsearch" {
  name                      = "elasticsearch"
  hostname                  = "elasticsearch"
  zone                      = "ru-central1-b" #c
  allow_stopping_for_update = true
  platform_id               = "standard-v1"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-elasticsearch.id}"
    }

  network_interface {
    subnet_id          = yandex_vpc_subnet.internal-subnet.id
    security_group_ids = [yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.30.31"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

#----------------- Kibana -----------------------------

resource "yandex_compute_instance" "kibana" {
  name                      = "kibana"
  hostname                  = "kibana"
  zone                      = "ru-central1-b" #c
  allow_stopping_for_update = true
  platform_id               = "standard-v1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-kibana.id}"
    }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana-rules.id, yandex_vpc_security_group.internal-rules.id]
    ip_address         = "192.168.40.42"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}
