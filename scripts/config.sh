#!/usr/bin/env bash


target_ip='192.168.203.5'
target_username='root'
config="/etc/vsftpd.conf"
user="Alice"
user_path="/home/${user}/ftp"
anonymity_path="/var/ftp/pub"

clientip="192.168.203.4"
nfs_sr="/home/ubuntu1/nfs_share_r"
nfs_srw="/home/ubuntu1/nfs_share_rw"

nfs_cr="/home/ubuntu1/nfs_share_r"
nfs_crw="/home/ubuntu1/nfs_share_rw"

dhcp_con1="/etc/dhcp/dhcpd.conf"
dhcp_con2="/etc/default/isc-dhcp-server"
dhcp_con3="/etc/netplan/01-netcfg.yaml"
