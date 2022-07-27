# FIREWALL: IPTABLES =====================================
resource "esxi_guest" "firewall" {

    guest_name  = "firewall"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-pfsense/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_vswitch.wan.name
    }

    network_interfaces {
        virtual_network = esxi_vswitch.dmz.name
    }

    network_interfaces {
        virtual_network = esxi_vswitch.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(file("firewall.cfg"))
        "metadata.encoding" = "gzip+base64"
    }

    provisioner "remote-exec" {
        inline = ["sudo yum update -y"]

        connection {
            host        = vm.private_ip_address
            type        = "ssh"
            user        = var.node_user
            password    = var.node_password
        }
    }

#   provisioner "local-exec" {
#       command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.pfsense_ip},' --extra-vars 'ansible_user=${var.pfsense_user} ansible_password=${var.pfsense_pass}' ../ansible/playbooks/pfsense/main.yml"
#   }
}
# ========================================================
