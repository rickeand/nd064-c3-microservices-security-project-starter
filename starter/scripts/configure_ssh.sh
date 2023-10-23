#!/bin/bash
ssh-keygen -t rsa -b 2048

rm -r ~/.ssh/known_hosts
sudo rm -r /root/.ssh/known_hosts

sudo ssh-copy-id -i ~/.ssh/id_rsa root@192.168.50.101
