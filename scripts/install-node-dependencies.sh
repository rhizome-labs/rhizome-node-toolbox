#!/bin/bash
apt-get update
apt-get install  -y systemd apt-transport-https ca-certificates curl gnupg-agent software-properties-common 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
usermod -aG docker $(whoami)
systemctl enable docker.service
systemctl start docker.service
apt-get install -y python-pip
pip install docker-compose
