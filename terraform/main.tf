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

# NETWORK: NAC 172.24.5.224-227 /24 ======================
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


# NETWORK: WAN 172.24.133.224-227 /24 ====================
resource "esxi_vswitch" "wan" {

    name = "vSwitch2"
    uplink {
        name = "vmnic3"
    }
}

resource "esxi_portgroup" "wan" {

    name = "Production_Network"
    vswitch = esxi_vswitch.wan.name
}
# ========================================================


# NETWORK: LAN 192.168.224.0 /24 =========================
resource "esxi_vswitch" "dmz" {

    name = "vSwitchDMZ"
}

resource "esxi_portgroup" "dmz" {

    name = "DMZ"
    vswitch = esxi_vswitch.dmz.name
}
# ========================================================


# NETWORK: LAN 192.168.225.0 /24 =========================
resource "esxi_vswitch" "lan" {

    name = "vSwitchLAN"
}

resource "esxi_portgroup" "lan" {

    name = "LAN"
    vswitch = esxi_vswitch.lan.name
}
# ========================================================
