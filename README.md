# hcloud-k8s

Install a Kubernetes Cluster on Hetzner Cloud.
The Playbook install a Master and Workers with Private Networking inclusive Cloud Controller Manager for Hetzner Cloud with a Load Balancer.

Tested Versions Kubernetes v1.19.6

---
## Local Requirements
  - Ansible v2.9.6 (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  - Terraform v0.14.7 (https://github.com/tfutils/tfenv#installation)
  - Kubectl v1.19.6 (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Prerequirement edit the following files
  - create a HCloud Project in Hetzner Cloud Console
  - copy/rename "env/values.yaml.example" to "env/values.yaml"
  - create a API Token and set in "env/values.yaml"
  - edit the values in "env/values.yaml"

## Prerequirement for Ingress & Let's Encrypt! support
  - Enable the Loadbalancer feature with setting `lb_enabled` to "true"
  - Enable the Ingress feature with setting `ingress_enabled` to "true"
  - Add for `lb_hostname` a valid DNS-Entry (necessary for Certificate Requests)
  - Add your email at `cert_email`

## Prerequirement for managing loadblancer DNS Entries
  - Add for `dns_zone_id` a valid DNS-Zone ID of the hetzner dns console (retrieve from the last DNS URI part -> https://dns.hetzner.com/zone/XXxxxxxXX")
  - Add for `dns_lb_a` a comma separated list of valid DNS A-Entries for the loadbalancer (wildcard is supported)
  - Add for `hetzner_dns_token` a valid Hetzner DNS API Token (retrieve from https://dns.hetzner.com/settings/api-token)

## Prerequirement for connecting to dedicated root servers
  - Enable the vSwitch feature with `vswitch_enabled` to "true"
  - Create a vSwitch and map it to your root server (explained here https://docs.hetzner.com/robot/dedicated-server/network/vswitch/)
  - Add for `vswitch_id` the ID of the created vSwitch

## Create Infrastructure Ansible Playbook Terrafom Module
```bash
ansible-playbook create-infrastructure.yaml
```
After creation is complete waiting 5 Minutes, because Hetzner install the "roles/tf-infrastructure/terraform/user-data/cloud-config.yaml" (Docker, Kubelet, Kubeadm, Kubectl, SSH Keys)
The Playbook execute Terraform and apply the resources. The working directory is "roles/tf-infrastructure/terraform/"

## Install Kubernetes Ansible Playbook
```bash
ansible-playbook k8s-install.yaml -i env/inventory
```
Install Kubernetes, Master, Workers, Load Balancer.

Test on your local machine if all works after few minutes:
```bash
kubectl get pods --all-namespaces
```

## Get Kube Config from Master Node
```bash
ansible-playbook get-kubeconfig.yaml -i env/inventory
```

## Delete Kubernetes and destroy Infrastructure Ansible Playbook Terrafom Module
```bash
ansible-playbook destroy-infrastructure.yaml
```
The Playbook execute Terraform and destroy the resources (Delete Instances, Load Balancers, Networks). The working directory is "roles/tf-infrastructure/terraform/"

## Add new nodes into cluster
```bash
ansible-playbook k8s-scale.yaml -i env/inventory
```
The playbook will setup new nodes and join them already created cluster. You should run this, if you have changed workers amount bigger after creating cluster from `env/values.yaml`.

## What's happening
  - Create Infrastructure on Hetzner Cloud with Terraform (roles/tf-infrastructure/terraform/)
    - Create 1 master
    - Create up to 4 different workers (depends on config-types)
    - (optional) Create a hetzner loadbalancer
    - (optional) Creata A-Records for the hetzner loadbalancer
    - (optional) Add the VLAN of your dedicated root servers
  - Prepare Kubernetes Tools and Configuration on all Servers
  - Install Master-Node
  - Join Worker-Nodes to Master
  - (optional) Install NGINX Ingress & Cert-Manager (Let's Encrypt! with prod & staging certificate)
  - Cleanup

## Caution Security
  - No network policy enabled (multi-tenancy is dangerous)
  - No pod policy - privileged pods are allowed
  - Instances/Cluster not secured by a VPC (also have public IPs)

### Credits

Credits for Installation Manual: https://github.com/cbeneke/

Ansible and Terraform created by: https://github.com/gammpamm/
