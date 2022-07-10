source "virtualbox-iso" "local"{

    iso_url = var.iso_url
    iso_checksum = var.iso_checksum
    
    boot_wait = "20s"
    boot_command = [
        "<tab><bs><bs><bs><bs><bs>text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    ]

    headless = false
    http_directory = "packer/centos7/http"
    guest_os_type = "RedHat_64"

    communicator = "ssh"
    ssh_port = 22

    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    ssh_timeout  = "25m"

    shutdown_command = "echo 'packer'|sudo -S /sbin/halt -h -p"
}



source "vmware-iso" "esxi"{

    vm_name = "centos7"
    vmdk_name = "centos7disk"

    iso_url = var.iso_url
    iso_checksum = var.iso_checksum

    disk_size = 20480 # 20 GB disk size
    disk_type_id = "thin"

    cd_files = [
        "./packer/centos7/http/ks.cfg"
    ]
    cd_label = "OEMDRV"

    boot_wait = "20s"
    boot_command = [
        "<tab><bs><bs><bs><bs><bs>text linux inst.ks=hd:/dev/sr1:ks.cfg<enter><wait>"
    ]

    headless = false
    http_directory = "packer/centos7/http"
    guest_os_type = "centos-64"

    communicator = "ssh"
    ssh_port = 22

    ssh_host     = var.ssh_host
    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
    ssh_timeout  = "25m"

    shutdown_command = "echo 'packer'|sudo -S /sbin/halt -h -p"

    remote_type             = "esx5"
    remote_host             = var.esxi_host
    remote_datastore        = var.esxi_datastore
    remote_cache_datastore  = var.esxi_cache_datastore
    remote_cache_directory  = "packer"
    remote_username         = var.esxi_username
    remote_password         = var.esxi_password

    # This must be set to "true" when using VNC with ESXi 6.5 or 6.7.
    vnc_disable_password    = true

    network_name = "WAN"
   
    format = "vmx"
    keep_registered = true
    vmx_remove_ethernet_interfaces = true
}


build {

    sources = ["source.vmware-iso.esxi", "source.virtualbox-iso.local"]

    provisioner "shell" {
        execute_command = "echo 'packer'|{{.Vars}} sudo -S -E bash '{{.Path}}'"
        inline = [
            "yum -y install epel-release",
            "yum -y update",
            "yum -y install ansible"
        ]
    }

    provisioner "ansible-local" {
        playbook_file = "packer/centos7/setup.yml"
    }

    provisioner "shell" {
        execute_command = "echo 'packer'|{{.Vars}} sudo -S -E bash '{{.Path}}'"
        inline = [
            "yum -y autoremove ansible",
            "yum clean all",
            "sync"
        ]
    }

    post-processor "vagrant" {
        keep_input_artifact = true
        output = "vagrant/boxes/centos7_{{.BuildName}}.box"
    }
}
