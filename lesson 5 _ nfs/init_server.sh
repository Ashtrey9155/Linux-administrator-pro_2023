#!/bin/bash

selinuxenabled && setenforce 0

cat > /etc/selinux/config <<SCPT
SELINUX = disabled
SELINUXTYPE = targeted
SCPT

yum install nfs-utils -y

systemctl enable firewalld --now
firewall-cmd --add-service="nfs3"
firewall-cmd --add-service="rpc-bind"

firewall-cmd   --reload

systemctl enable nfs --now

mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

echo "/srv/share 192.168.56.42/32(rw,sync,root_squash)" >> /etc/exports
exportfs -r

systemctl enable rpcbind
systemctl enable nfs-server
systemctl start rpcbind
systemctl start nfs-server

firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind

firewall-cmd --reload
