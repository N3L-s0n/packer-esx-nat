terraform {
    required_version = ">= 0.12"
    required_providers {
        esxi = {
            source = "registry.terraform.io/josenk/esxi"
        }
    }
}

provider "esxi" {
    esxi_hostname   = var.esxi_hostname
    esxi_hostport   = var.esxi_hostport
    esxi_username   = var.esxi_username
    esxi_password   = var.esxi_password
}

# NETWORK: NAC 172.24.5.x ================================
resource "esxi_vswitch" "nac" {

    name = "NAC"
    uplink {
        name = "vmnic2"
    }
}

resource "esxi_portgroup" "nac" {

    name = "NAC"
    vswitch = esxi_vswitch.nac.name
}
# ========================================================


# NETWORK: WAN 172.24.133.x ==============================
resource "esxi_vswitch" "wan" {

    name = "WAN"
    uplink {
        name = "vmnic3"
    }
}

resource "esxi_portgroup" "wan" {

    name = "WAN"
    vswitch = esxi_vswitch.wan.name
}
# ========================================================


# NETWORK: LAN ===========================================
resource "esxi_vswitch" "lan" {

    name = "LAN"
}

resource "esxi_portgroup" "lan" {

    name = "LAN"
    vswitch = esxi_vswitch.lan.name
}
# ========================================================



# FIREWALL: PFSENSE ======================================
resource "esxi_guest" "firewall" {

    guest_name  = "firewall"
    disk_store  = "vmstorage"

    ovf_source  = "../output-pfsense/pfsense.vmx"

    network_interfaces {
        virtual_network = esxi_vswitch.wan.name
    }

    network_interfaces {
        virtual_network = esxi_vswitch.lan.name
    }

    network_interfaces {
        virtual_network = esxi_vswitch.nac.name
    }

    provisioner "remote-exec" {
        inline = ["pkg update"]

        connection {
            host        = var.pfsense_ip
            type        = "ssh"
            user        = var.pfsense_user
            password    = var.pfsense_pass
        }
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.pfsense_ip},' --extra-vars 'ansible_user=${var.pfsense_user} ansible_password=${var.pfsense_pass}' ../ansible/playbooks/pfsense/main.yml"
    }
}
# ========================================================


# SERVER: DB =============================================
resource "esxi_guest" "db" {

    guest_name      = "db"
    disk_store      = "vmstorage"

    ovf_source      = "../output-centos/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_vswitch.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("db-network.cfg"))
        "metadata.encoding" = "gzip+base64"
    }

    provisioner "remote-exec" {
        inline = ["sudo yum update -y"]

        connection {
            host        = var.pfsense_ip
            port        = var.db_dnat_port
            type        = "ssh"
            user        = var.server_user
        }
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.pfsense_ip}:${var.db_dnat_port},' --extra-vars 'ansible_user=${var.server_user} }' ../ansible/playbooks/db/main.yml"
    }
}
# ========================================================


# SERVER: APP ============================================
resource "esxi_guest" "app" {

    guest_name      = "app"
    disk_store      = "vmstorage"

    ovf_source      = "../output-centos/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_vswitch.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("app-network.cfg"))
        "metadata.encoding" = "gzip+base64"
    }

    provisioner "remote-exec" {
        inline = ["sudo yum update -y"]

        connection {
            host        = var.pfsense_ip
            port        = var.app_dnat_port
            type        = "ssh"
            user        = var.server_user
        }
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.pfsense_ip}:${var.app_dnat_port},' --extra-vars 'ansible_user=${var.server_user} ' ../ansible/playbooks/www/main.yml"
    }
}
# ========================================================
