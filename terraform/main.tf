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

# NETWORK: NAC 172.24.5.64-67 /24 ========================
resource "esxi_vswitch" "nac" {

    name = "vSwitchNAC"
    uplink {
        name = "vmnic2"
    }
}

resource "esxi_portgroup" "nac" {

    name = "NAC"
    vswitch = esxi_vswitch.nac.name
}
# ========================================================


# NETWORK: WAN 172.24.133.64-67 /24 ======================
resource "esxi_vswitch" "wan" {

    name = "vSwitchWAN"
    uplink {
        name = "vmnic3"
    }
}

resource "esxi_portgroup" "wan" {

    name = "WAN"
    vswitch = esxi_vswitch.wan.name
}
# ========================================================


# ========================================================


# NETWORK: LAN 192.168.64.0 /24 ==========================
resource "esxi_vswitch" "lan" {

    name = "vSwitchLAN"
}

resource "esxi_portgroup" "lan" {

    name = "LAN"
    vswitch = esxi_vswitch.lan.name
}
# ========================================================
