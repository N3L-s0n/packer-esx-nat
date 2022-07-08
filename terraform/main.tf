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
        virtual_network = esxi_vswitch.lan.name
        virtual_network = esxi_vswitch.nac.name
    }

    provisioner "remote-exec" {
        inline = ["echo waiting..."]

        connection {
            host        = self.ipv4_address
            type        = "ssh"
            user        = var.pfsense_user
            password    = var.pfsense_pass
        }
    }
}

# ESXi Guest Test Machine
#resource "esxi_guest" "vmtest" {
#    
#    guest_name      = "vmtest"
#    disk_store      = "vmstorage"
#
#    ovf_source      = "../output-centos/centos7.vmx"
#
#    network_interfaces {
#        virtual_network = "LAN"
#    }
#
#    guestinfo = {
#        "metadata" = base64gzip(file("test-network.cfg"))
#        "metadata.encoding" = "gzip+base64"
#    }
#}
