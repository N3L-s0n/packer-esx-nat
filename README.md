# Archipress

This repository contains code to deploy a WordPress installation on a two-server LAMP infraestructure with one playing the role of an application server and the other a remote DB. The repository has many stages, first we develop Vagrant Boxes with Packer, then we must deploy a pfsense or other machine to have network connection and DHCP in order to run the Vagranfile with our servers. After we have our boxes running we can start provisioning them with the Ansible playbooks added in the repository. 

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
