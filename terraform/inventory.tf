data "template_file" "ansible_firewall_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.firewall]
    
    vars = {
        node_name       = esxi_guest.firewall.name
        ansible_user    = var.node_user
        ip              = esxi_guest.firewall.ip_address
    }
}


data "template_file" "ansible_app_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.app]
    
    vars = {
        node_name       = esxi_guest.app.name
        ansible_user    = var.node_user
        ip              = esxi_guest.app.ip_address
    }
}


data "template_file" "ansible_skeleton" {
    
    template = file("${path.root}/templates/ansible_skeleton.tpl") 

    vars = {
        firewall_host_def   = join("", data.template_file.ansible_firewall_host.rendered)
        app_host_def        = join("", data.template_file.ansible_app_host.rendered)
    }
}

# Write Ansible Inventory to file
resource "local_file" "ansible_inventory" {
    
    depends_on = [data.template_file.ansible_skeleton]

    content = data.template_file.ansible_skeleton.rendered
    filename = "${path.root}/inventory"

}
