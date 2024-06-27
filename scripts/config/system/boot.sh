#!/bin/bash

# Ensure correct dns resolution
sed -i '/nameserver/d' /etc/resolv.conf
ip route show | grep -i default | awk '{ print "nameserver "$3}' | tee -a /etc/resolv.conf > /dev/null

# Ensure passwordless root authentication for method 'mysql_native_password'
# (The update procedure of MySQL tends to change the authentication method for default users)
mysql -uroot -e "ALTER user 'root'@'localhost' IDENTIFIED WITH mysql_native_password by ''"
