#!/bin/bash

sed -i '/nameserver/d' /etc/resolv.conf

ip route show | grep -i default | awk '{ print "nameserver "$3}' | tee -a /etc/resolv.conf > /dev/null
