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
