
#cloud-config
network:
    version: 2
    ethernets:
        ens32:
            addresses: [${ip_address}]
            gateway4: ${gateway_address}
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
