#!/bin/bash

selinuxenabled && setenforce 0

cat > /etc/selinux/config <<SCPT
SELINUX = disabled
SELINUXTYPE = targeted
SCPT

yum install nfs-utils  -y

systemctl enable firewalld --now

echo "192.168.56.41:/srv/share/ /mnt/ nfs rw,sync,hard,intr 0 0" >> /etc/fstab

systemctl daemon-reload
systemctl restart remote-fs.target
