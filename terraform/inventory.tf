data "template_file" "ansible_firewall_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.firewall]
    
    vars = {
        node_name       = esxi_guest.firewall.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.firewall.ip_address
    }
}

data "template_file" "ansible_app_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.app]
    
    vars = {
        node_name       = esxi_guest.app.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.app.ip_address
    }
}

data "template_file" "ansible_db_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.db]
    
    vars = {
        node_name       = esxi_guest.db.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.db.ip_address
    }
}

data "template_file" "ansible_proxy_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.proxy]
    
    vars = {
        node_name       = esxi_guest.proxy.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.proxy.ip_address
    }
}

data "template_file" "ansible_admin_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.admin]
    
    vars = {
        node_name       = esxi_guest.admin.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.admin.ip_address
    }
}


data "template_file" "ansible_skeleton" {
    
    template = file("${path.root}/templates/ansible_skeleton.tpl") 

    vars = {
        firewall_host_def   = data.template_file.ansible_firewall_host.rendered
        app_host_def        = data.template_file.ansible_app_host.rendered
        db_host_def         = data.template_file.ansible_db_host.rendered
        proxy_host_def      = data.template_file.ansible_proxy_host.rendered
        admin_host_def      = data.template_file.ansible_admin_host.rendered
    }
}

data "template_file" "variables_skeleton" {

    template = file("${path.root}/templates/ansible_variables.tpl")
    depends_on = [esxi_guest.firewall, esxi_guest.app]

    vars = {
        wan_network     = var.wan_network 
        lan_network     = var.lan_network 
        dmz_network     = var.dmz_network 
        
        firewall_addr   = esxi_guest.firewall.ip_address
        app_addr        = esxi_guest.app.ip_address
        db_addr         = esxi_guest.db.ip_address
        proxy_addr      = esxi_guest.proxy.ip_address
        admin_addr      = esxi_guest.admin.ip_address
    }
}

# Write Ansible Inventory to file
resource "local_file" "ansible_inventory" {
    
    depends_on = [data.template_file.ansible_skeleton]

    content = data.template_file.ansible_skeleton.rendered
    filename = "${path.root}/inventory"
    file_permission = "0666"
}

resource "local_file" "ansible_variables" {
    
    depends_on = [data.template_file.variables_skeleton]

    content = data.template_file.variables_skeleton.rendered
    filename = "${path.root}/variables.yml"
    file_permission = "0666"
}

resource "null_resource" "ansible_run" {

    depends_on = [
        resource.esxi_guest.firewall, 
        resource.esxi_guest.app, 
        resource.esxi_guest.db, 
        resource.esxi_guest.proxy, 
        resource.esxi_guest.admin, 

        resource.local_file.ansible_inventory,
        resource.local_file.ansible_variables
    ]

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.root}/inventory --extra-vars '@${path.root}/variables.yml' ${path.root}/../ansible/playbook.yml"
    }
}
