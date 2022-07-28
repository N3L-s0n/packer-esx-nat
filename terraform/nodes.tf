# FIREWALL: IPTABLES =====================================
resource "esxi_guest" "firewall" {

    guest_name  = "firewall"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.wan.name
    }

    network_interfaces {
        virtual_network = esxi_portgroup.dmz.name
    }

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("cloud-init/firewall.cfg"))
        "metadata.encoding" = "gzip+base64"
    }

    provisioner "remote-exec" {
        inline = ["sudo yum update -y"]

        connection {
            host        = self.ip_address
            type        = "ssh"
            user        = var.node_user
            agent       = true
        }
    }

#   provisioner "local-exec" {
#       command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.pfsense_ip},' --extra-vars 'ansible_user=${var.pfsense_user} ansible_password=${var.pfsense_pass}' ../ansible/playbooks/pfsense/main.yml"
#   }
}
# ========================================================

# APP DMZ ================================================
resource "esxi_guest" "app" {

    guest_name  = "app"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.dmz.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("cloud-init/app.cfg"))
        "metadata.encoding" = "gzip+base64"
    }
}
# ========================================================


# DB LAN =================================================
resource "esxi_guest" "db" {

    guest_name  = "db"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("cloud-init/db.cfg"))
        "metadata.encoding" = "gzip+base64"
    }
}
# ========================================================

# PROXY LAN ==============================================
resource "esxi_guest" "proxy" {

    guest_name  = "proxy"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("cloud-init/proxy.cfg"))
        "metadata.encoding" = "gzip+base64"
    }
}
# ========================================================

# ADMIN LAN ==============================================
resource "esxi_guest" "admin" {

    guest_name  = "admin"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("cloud-init/admin.cfg"))
        "metadata.encoding" = "gzip+base64"
    }
}
# ========================================================
