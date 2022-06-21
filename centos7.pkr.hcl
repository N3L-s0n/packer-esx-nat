source "virtualbox-iso" "local"{

    iso_url = var.iso_url
    iso_checksum = var.iso_checksum
    
    boot_wait = "20s"
    boot_command = [
        "<tab><bs><bs><bs><bs><bs>text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    ]

    headless = false
    http_directory = "http"
    guest_os_type = "RedHat_64"

    communicator = "ssh"
    ssh_port = 22

    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    ssh_timeout  = "25m"

    shutdown_command = "echo 'packer'|sudo -S /sbin/halt -h -p"
}



source "vmware-iso" "esxi"{

    iso_url = var.iso_url
    iso_checksum = var.iso_checksum
    
    boot_wait = "20s"
    boot_command = [
        "<tab><bs><bs><bs><bs><bs>text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    ]

    headless = false
    http_directory = "http"
    guest_os_type = "centos-64"

    communicator = "ssh"
    ssh_port = 22

    ssh_bastion_host = var.bastion_host
    ssh_bastion_username = var.bastion_username
    ssh_bastion_password = var.bastion_password

    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    ssh_timeout  = "25m"

    shutdown_command = "echo 'packer'|sudo -S /sbin/halt -h -p"

    remote_type = "esx5"
    remote_host = var.esxi_host
    remote_datastore = var.esxi_datastore
    remote_username = var.esxi_username
    remote_password = var.esxi_password
}


build {

    sources = ["source.vmware-iso.esxi"]

    provisioner "shell" {
        execute_command = "echo 'packer'|{{.Vars}} sudo -S -E bash '{{.Path}}'"
        inline = [
            "yum -y install epel-release",
            "yum -y update"
        ]
    }
}
