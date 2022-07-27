---
# firewall variables

networks:
  - name: wan
    type: public
    ipv4: ${wan_network}
    prefix: "24"

    forward_from:
      - { "src_network": "dmz", "src_addr": "network", "src_port": "any", "dest_addr": "any", "dest_port": "80"}
      - { "src_network": "dmz", "src_addr": "network", "src_port": "any", "dest_addr": "any", "dest_port": "443"}
      - { "src_network": "dmz", "src_addr": ${app_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "25"}
      - { "src_network": "dmz", "src_addr": ${app_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "587"}
      - { "src_network": "dmz", "src_addr": ${app_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "995"}

      - { "src_network": "lan", "src_addr": ${admin_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "21"}

      - { "src_network": "lan", "src_addr": ${proxy_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "80"}
      - { "src_network": "lan", "src_addr": ${proxy_addr}, "src_port": "any", "dest_addr": "any", "dest_port": "443"}

  - name: dmz
    type: private
    ipv4: ${dmz_network}
    prefix: "24"

    forward_from:
      - { "src_network": "wan", "src_addr": "any", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "80"}
      - { "src_network": "wan", "src_addr": "any", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "443"}
      - { "src_network": "wan", "src_addr": "any", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "25"}
      - { "src_network": "wan", "src_addr": "any", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "587"}
      - { "src_network": "wan", "src_addr": "any", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "995"}

      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "80"}
      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "443"}
      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "25"}
      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "587"}
      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "995"}
      - { "src_network": "lan", "src_addr": ${admin_addr}, "src_port": "any", "dest_addr": "network", "dest_port": "22"}
      - { "src_network": "lan", "src_addr": ${db_addr}, "src_port": "any", "dest_addr": ${app_addr}, "dest_port": "3306"}

  - name: lan
    type: private
    ipv4: ${lan_network}
    prefix: "24"

    forward_from:
      - { "src_network": "lan", "src_addr": "network", "src_port": "any", "dest_addr": "network", "dest_port": "22"}

dnat_tcp:
  25  : ${app_addr} # SMTP
  80  : ${app_addr} # HTTP
  443 : ${app_addr} # HTTPS
  587 : ${app_addr} # SMTP
  995 : ${app_addr} # POP3s

vpn_client_ipv4: "10.0.0.1"
vpn_server_ipv4: "10.0.0.2"
vpn_remote_ipv4: ${firewall_addr}

vpn_routes: 
  - { "ipv4": ${dmz_network}, "netmask": "255.255.255.0" }
  - { "ipv4": ${lan_network}, "netmask": "255.255.255.0" }
