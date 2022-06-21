# packer-esx-nat

This build works with a local virtual box installation and remote esxi host using vmware-iso as source. CentOS 7 requires a kickstart file which is located in the http folder, this file has initial installation options like keyboard and language.

The remote esxi host should have a virtual machine running a **DHCP** server since no static IP is configured. The remote build was done with a ssh bastion in mind, my infraestructure has a LAN network where the VM will be build, in order to get ssh access for the communicator there is a desktop machine in the LAN using NAT, so the communicator then can have access to the build's private IP address through this desktop.

A variables file must be created, with the values needed in the centos7.pkr.hcl file, those have the expression **var.\*** .

## Kickstart ##
This build installs from cdrom with a minimal CentOs 7 image, enables firewall with ssh allowed and uses SELinux with enforcing. It creates a user with username and password packer, these values should be set in the variables file for the ssh connection when provisioning.

## Provisioning ##
Working on this ...

## Run ##
To start the build execute the following command if variables file properly created
```sh
packer build centos7.pkr.hcl -var-file variables.pkr.hcl
```
