provider "hcloud" {
  token = var.hcloud_token
}

# Private Network and subnets
resource "hcloud_network" "default" {
  name     = "kubernetes"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "master" {
  network_id   = hcloud_network.default.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"

  depends_on = [hcloud_network.default]
}

resource "hcloud_network_subnet" "worker" {
  network_id   = hcloud_network.default.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.2.0/24"

  depends_on = [hcloud_network.default]
}

resource "hcloud_network_subnet" "vswitch" {
  count = var.lb_enabled ? 1 : 0

  network_id   = hcloud_network.default.id
  type         = "vswitch"
  ip_range     = "10.0.3.0/24"
  network_zone = "eu-central"
  vswitch_id   = var.vswitch_id

  depends_on = [hcloud_network.default]
}

resource "hcloud_server" "master" {
  count       = 1
  name        = "master"
  image       = "ubuntu-18.04"
  server_type = var.master_servertype
  location    = var.datacenter
  user_data   = file("./user-data/cloud-config.yaml")
}

resource "hcloud_rdns" "rdns_master" {
  count      = length(hcloud_server.master)
  server_id  = hcloud_server.master[count.index].id
  ip_address = hcloud_server.master[count.index].ipv4_address
  dns_ptr    = "master.${var.domain}"

  depends_on = [hcloud_server.master]
}

resource "hcloud_server_network" "master_network" {
  count      = length(hcloud_server.master)
  subnet_id  = hcloud_network_subnet.master.id
  server_id  = hcloud_server.master.*.id[count.index]
  ip         = "10.0.1.${count.index + 2}"

  depends_on = [hcloud_server.master, hcloud_network_subnet.master]
}

# Worker
resource "hcloud_server" "worker1" {
  count       = var.worker1_count
  name        = "node1-${count.index + 1}"
  image       = "ubuntu-18.04"
  server_type = var.worker1_servertype
  location    = var.datacenter
  user_data   = file("./user-data/cloud-config.yaml")
  labels      = {"lb" = "node1-${count.index + 1}","type" = "worker1"}
}

resource "hcloud_server" "worker2" {
  count       = var.worker2_count
  name        = "node2-${count.index + 1}"
  image       = "ubuntu-18.04"
  server_type = var.worker2_servertype
  location    = var.datacenter
  user_data   = file("./user-data/cloud-config.yaml")
  labels      = {"lb" = "node2-${count.index + 1}","type" = "worker2"}
}

resource "hcloud_server" "worker3" {
  count       = var.worker3_count
  name        = "node3-${count.index + 1}"
  image       = "ubuntu-18.04"
  server_type = var.worker3_servertype
  location    = var.datacenter
  user_data   = file("./user-data/cloud-config.yaml")
  labels      = {"lb" = "node3-${count.index + 1}","type" = "worker3"}
}

resource "hcloud_server" "worker4" {
  count       = var.worker4_count
  name        = "node4-${count.index + 1}"
  image       = "ubuntu-18.04"
  server_type = var.worker4_servertype
  location    = var.datacenter
  user_data   = file("./user-data/cloud-config.yaml")
  labels      = {"lb" = "node4-${count.index + 1}","type" = "worker4"}
}

resource "hcloud_rdns" "rdns_worker1" {
  count      = length(hcloud_server.worker1)
  server_id  = hcloud_server.worker1[count.index].id
  ip_address = hcloud_server.worker1[count.index].ipv4_address
  dns_ptr    = "node1-${count.index + 1}.${var.domain}"

  depends_on = [hcloud_server.worker1]
}

resource "hcloud_rdns" "rdns_worker2" {
  count      = length(hcloud_server.worker2)
  server_id  = hcloud_server.worker2[count.index].id
  ip_address = hcloud_server.worker2[count.index].ipv4_address
  dns_ptr    = "node2-${count.index + 1}.${var.domain}"

  depends_on = [hcloud_server.worker2]
}

resource "hcloud_rdns" "rdns_worker3" {
  count      = length(hcloud_server.worker3)
  server_id  = hcloud_server.worker3[count.index].id
  ip_address = hcloud_server.worker3[count.index].ipv4_address
  dns_ptr    = "node3-${count.index + 1}.${var.domain}"

  depends_on = [hcloud_server.worker3]
}

resource "hcloud_rdns" "rdns_worker4" {
  count      = length(hcloud_server.worker4)
  server_id  = hcloud_server.worker4[count.index].id
  ip_address = hcloud_server.worker4[count.index].ipv4_address
  dns_ptr    = "node4-${count.index + 1}.${var.domain}"

  depends_on = [hcloud_server.worker4]
}

resource "hcloud_server_network" "worker_network" {
  count      = length(hcloud_server.worker1) + length(hcloud_server.worker2) + length(hcloud_server.worker3) + length(hcloud_server.worker4)
  subnet_id  = hcloud_network_subnet.worker.id
  server_id  = element(concat(hcloud_server.worker1.*.id,
                      hcloud_server.worker2.*.id,
                      hcloud_server.worker3.*.id,
                      hcloud_server.worker4.*.id), count.index)
  ip         = "10.0.2.${count.index + 2}"

  depends_on = [hcloud_server.worker1, hcloud_server.worker2, hcloud_server.worker3, hcloud_server.worker4, hcloud_network_subnet.worker]
}

resource "hcloud_load_balancer" "k8s-loadbalancer" {
  count = var.lb_enabled ? 1 : 0

  load_balancer_type = var.lb_type
  location = var.lb_datacenter
  name = "k8s-loadbalancer"
}

resource "hcloud_load_balancer_network" "kubernetes" {
  count = var.lb_enabled ? 1 : 0

  load_balancer_id = hcloud_load_balancer.k8s-loadbalancer[0].id
  subnet_id = hcloud_network_subnet.worker.id
  ip = "10.0.2.1"

  depends_on = [hcloud_network_subnet.worker, hcloud_load_balancer.k8s-loadbalancer]
}

resource "hcloud_load_balancer_target" "k8s-targets" {
  count = var.lb_enabled ? 1 : 0

  load_balancer_id = hcloud_load_balancer.k8s-loadbalancer[0].id
  type = "label_selector"
  label_selector = "lb"
  use_private_ip = true

  depends_on = [hcloud_load_balancer_network.kubernetes]
}
