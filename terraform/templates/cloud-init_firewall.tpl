#cloud-config
network:
    version: 2
    ethernets:
        ens32:
            addresses: [${firewall_public_ipv4}]
            gateway4: ${firewall_gateway_ipv4}
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
        ens33:
            addresses: [${firewall_private_ipv4}]
