# FIREWALL: IPTABLES =====================================
resource "esxi_guest" "firewall" {

    guest_name  = "firewall"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.wan.name
    }

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(templatefile("templates/cloud-init_firewall.tpl", 
                    {
                        "firewall_public_ipv4"  = var.firewall_public_ipv4,
                        "firewall_private_ipv4" = var.firewall_private_ipv4,
                        "firewall_gateway_ipv4" = var.firewall_gateway_ipv4
                    }))
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
}

# DB =====================================================
resource "esxi_guest" "db" {

    count = length(var.db_servers)
    guest_name  = "db${count.index + 1}"

    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(templatefile("templates/cloud-init_server.tpl", 
                    { 
                        "ip_address" = element(var.db_servers, count.index), 
                        "gateway_address" = var.firewall_private_ipv4
                    }))

        "metadata.encoding" = "gzip+base64"
    }
}

# APP LAN ================================================
resource "esxi_guest" "app" {

    count = length(var.app_servers)
    guest_name  = "app${count.index + 1}"

    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(templatefile("templates/cloud-init_server.tpl", 
                    { 
                        "ip_address" = element(var.db_servers, count.index), 
                        "gateway_address" = var.firewall_private_ipv4
                    }))
        "metadata.encoding" = "gzip+base64"
    }

}
# LOAD BALANCE LAN =======================================
resource "esxi_guest" "lb" {

    count = length(var.lb_servers)
    guest_name  = "lb${count.index + 1}"
    disk_store  = var.esxi_datastore

    ovf_source  = "../output-esxi/centos7.vmx"

    network_interfaces {
        virtual_network = esxi_portgroup.lan.name
    }

    guestinfo = {
        "metadata" = base64gzip(templatefile("templates/cloud-init_server.tpl", 
                    { 
                        "ip_address" = element(var.db_servers, count.index), 
                        "gateway_address" = var.firewall_private_ipv4
                    }))
        "metadata.encoding" = "gzip+base64"
    }
}
