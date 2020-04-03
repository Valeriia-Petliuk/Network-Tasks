#!/bin/bash


set -x

# Netplan configuration
rm /etc/netplan/50-vagrant.yaml
cp /vagrant/NAT/50-vagrant.yaml /etc/netplan
netplan apply

# IpTables configuration
iptables -A FORWARD -i enp0s8 -j ACCEPT
iptables -A FORWARD -o enp0s8 -j ACCEPT
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to-destination 172.16.2.106

# Install iptables-persistent
apt update
DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
iptables-save > /etc/iptables/rules.v4

# Upload iptables-save
if ! grep -q "@reboot root iptables-restore < /etc/iptables/rules.v4" /etc/crontab; 
then echo "@reboot root iptables-restore < /etc/iptables/rules.v4" >> /etc/crontab; 
fi

# Enable ip forwarding
sysctl -w net.ipv4.ip_forward=1
