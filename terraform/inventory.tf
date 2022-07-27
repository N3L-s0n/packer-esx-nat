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


data "template_file" "ansible_skeleton" {
    
    template = file("${path.root}/templates/ansible_skeleton.tpl") 

    vars = {
        firewall_host_def   = data.template_file.ansible_firewall_host.rendered
        app_host_def        = data.template_file.ansible_app_host.rendered
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
