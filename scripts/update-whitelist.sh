#!/bin/bash
wget 'https://download.solidwallet.io/conf/prep_iplist.json' -O /etc/haproxy/whitelist-temp.lst
mv /etc/haproxy/whitelist.lst /etc/haproxy/whitelist-bkp.lst
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /etc/haproxy/whitelist-temp.lst > /etc/haproxy/whitelist.lst
sudo service haproxy reload
rm -rf whitelist-bkp.lst
rm -rf whitelist-temp.lst
