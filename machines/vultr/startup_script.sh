#!/bin/sh

apt install bash
rm /bin/sh
ln -s bash /bin/sh
useradd --create-home -p "saVTdNHrmIiTI" -g users -s "$(which bash)"  coco
echo "coco ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
mkdir "/home/coco/.ssh"
curl "https://github.com/Cocossoul.keys" >> /home/coco/.ssh/authorized_keys
chown --recursive coco:users "/home/coco/.ssh"
