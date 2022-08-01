data "template_file" "ansible_firewall_host" {

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.firewall]
    
    vars = {
        node_name       = esxi_guest.firewall.guest_name
        ansible_user    = var.node_user
        ip              = esxi_guest.firewall.ip_address
        extra_vars      = ""
    }
}

data "template_file" "ansible_db_hosts" {

    count = length(var.db_servers)

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.db]
    
    vars = {
        node_name       = esxi_guest.db[count.index]["guest_name"]
        ansible_user    = var.node_user
        ip              = esxi_guest.db[count.index]["ip_address"]
        extra_vars      = ""
    }
}


data "template_file" "ansible_app_hosts" {

    count = length(var.app_servers)

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.app]
    
    vars = {
        node_name       = esxi_guest.app[count.index]["guest_name"]
        ansible_user    = var.node_user
        ip              = esxi_guest.app[count.index]["ip_address"]
        extra_vars      = ""
    }
}

data "template_file" "ansible_lb_hosts" {

    count = length(var.lb_servers)

    template = file("${path.root}/templates/ansible_hosts.tpl") 
    depends_on = [esxi_guest.lb]
    
    vars = {
        node_name       = esxi_guest.lb[count.index]["guest_name"]
        ansible_user    = var.node_user
        ip              = esxi_guest.lb[count.index]["ip_address"]
        extra_vars      = join("", ["ka_priority=", count.index == 0 ? "10" : "9", " ka_password=", var.ka_password, " ka_virtual_ipv4=", var.app_address])
    }
}

data "template_file" "ansible_skeleton" {
    
    template = file("${path.root}/templates/ansible_skeleton.tpl") 

    vars = {
        firewall_host_def   = data.template_file.ansible_firewall_host.rendered
        app_host_def        = join("", data.template_file.ansible_app_hosts.*.rendered)
        db_host_def         = join("", data.template_file.ansible_db_hosts.*.rendered)
        lb_host_def         = join("", data.template_file.ansible_lb_hosts.*.rendered)
    }
}

data "template_file" "variables_skeleton" {

    template = file("${path.root}/templates/ansible_variables.tpl")
    depends_on = [esxi_guest.firewall, esxi_guest.app, esxi_guest.db, esxi_guest.lb]

    vars = {
        wan_network     = var.wan_network 
        lan_network     = var.lan_network 
        
        firewall_addr   = esxi_guest.firewall.ip_address
        app_addr        = var.app_address

        database_name   = var.database_name
        database_user   = var.database_user
        database_password = var.database_password

        wordpress_user = var.wordpress_user
        wordpress_password = var.wordpress_password
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

#resource "null_resource" "ansible_run" {

    #depends_on = [
        #resource.esxi_guest.firewall, 
        #resource.esxi_guest.app, 
        #resource.esxi_guest.db, 
        #resource.esxi_guest.proxy, 
        #resource.esxi_guest.admin, 

        #resource.local_file.ansible_inventory,
        #resource.local_file.ansible_variables
    #]

    #provisioner "local-exec" {
        #command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.root}/inventory --extra-vars '@${path.root}/variables.yml' ${path.root}/../ansible/playbook.yml"
    #}
#}
