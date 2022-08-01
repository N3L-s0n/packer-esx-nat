---
# system variables

http_host: "www.archipress.com"
db_name: ${database_name}
db_user: ${database_user}
db_password: ${database_password}

wp_user: ${wordpress_user}
wp_password: ${wordpress_password}

networks:
  - name: "wan"
    type: "public"
    ipv4: ${wan_network}
    prefix: "24"

    forward_from: # FORWARD TO WAN
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "any", "dest_port" : "80"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "any", "dest_port" : "443"}
  

  - name: "lan"
    type: "private"
    ipv4: ${lan_network}
    prefix: "24"

    forward_from: # FORWARD TO LAN
      - { "src_network" : "wan", "src_addr" : "any", "src_port" : "any", "dest_addr" : ${app_addr}, "dest_port" : "80"}
      - { "src_network" : "wan", "src_addr" : "any", "src_port" : "any", "dest_addr" : ${app_addr}, "dest_port" : "443"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "80"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "443"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "3306"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "4567"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "4568"}
      - { "src_network" : "lan", "src_addr" : "network", "src_port" : "any", "dest_addr" : "network", "dest_port" : "4444"}

dnat_tcp: # PREROUTING
  80  : ${app_addr} # HTTP
  443 : ${app_addr} # HTTPS

# VPN VARIABLES
vpn_client_ipv4: "10.0.0.1"
vpn_server_ipv4: "10.0.0.2"
vpn_remote_ipv4: ${firewall_addr}

vpn_routes:
  - ipv4: ${lan_network}
    netmask: "255.255.255.0"
