#----------------- VPC -----------------------------
resource "yandex_vpc_network" "network-1" {
  name = "network-1"
  description  = "network-1"
}

resource "yandex_vpc_route_table" "routing-table" {
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
  }
}

#----------------- Subnets -----------------------------

resource "yandex_vpc_subnet" "subnet-web-1" {
  name           = "subnet-web-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.routing-table.id
}

resource "yandex_vpc_subnet" "subnet-web-2" {
  name           = "subnet-web-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.routing-table.id
}

resource "yandex_vpc_subnet" "internal-subnet" {
  name           = "internal-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.routing-table.id
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.40.0/24"]
}


#----------------- target_group -----------------

resource "yandex_alb_target_group" "target-group" {
  name = "target-group"

  target {
    ip_address = yandex_compute_instance.web-1.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.subnet-web-1.id
  }

  target {
    ip_address = yandex_compute_instance.web-2.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.subnet-web-2.id
  }
}

#----------------- Backend_group -----------------

resource "yandex_alb_backend_group" "backend-group" {
  name = "backend-group"

  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.target-group.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

#----------------- HTTP router -----------------

resource "yandex_alb_http_router" "http-router" {
  name = "http-router"
}

resource "yandex_alb_virtual_host" "root-virtual-host" {
  name           = "root-virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "main-route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}

#----------------- L7 balancer -----------------

resource "yandex_alb_load_balancer" "load-balancer" {
  name               = "load-balancer"
  network_id         = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.load-balancer-rules.id, yandex_vpc_security_group.internal-rules.id] 

    listener {
    name = "listener-1"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}
#----------------- Security_group -----------------

resource "yandex_vpc_security_group" "internal-rules" {
  name       = "internal-rules"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from inner subnets"
    v4_cidr_blocks = ["192.169.10.0/24", "192.169.20.0/24", "192.169.30.0/24", "192.169.40.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion-rules" {
  name       = "bastion-rules"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "allow zabbix connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix-rules" {
  name       = "zabbix-rules"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "allow zabbix connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow zabbix connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana-rules" {
  name       = "kibana-rules"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "load-balancer-rules" {
  name       = "load-balancer-rules"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
