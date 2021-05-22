#!/bin/bash
mkfs.xfs -L data /dev/xvdh
mount -L data /data
echo LABEL=data /data defaults,nofail 0 2 >> /etc/fstab

apt install nginx -y
echo "Hello, Stockbit Test" > /var/www/html/index.html
systemctl start nginx
systemctl enable nginx