#!/bin/sh
# Скрипт забирает hosts файл из репозитория StevenBlack и конвертирует его в формат unbound
# Не забудьте добавить в конфиг unbound
# 	include: /etc/unbound/blocking-data-ipv4.conf
# 	include: /etc/unbound/blocking-data-ipv6.conf

curl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | grep "^0.0.0.0" | sort -u > /etc/hosts.ipv4-deny  
sed -i s/0.0.0.0/127.0.0.1/g /etc/hosts.ipv4-deny
sed -i '/127.0.0.1 127.0.0.1/d' /etc/hosts.ipv4-deny

cp /etc/hosts.ipv4-deny /etc/hosts.ipv6-deny 
sed -i s/127.0.0.1/::1/g /etc/hosts.ipv6-deny
sed -i '/::1 ::1/d' /etc/hosts.ipv6-deny

# \x22 двойные кавычки в hex
cat/etc/hosts.ipv4-deny /etc/hosts.blocking | grep "^127.0.0.1" | awk '{ print "local-data: \x22"$2,"A 127.0.0.1\x22"}' | sort -u > /etc/unbound/blocking-data-ipv4.conf
cat /etc/hosts.ipv4-deny /etc/hosts.blocking | grep "^127.0.0.1" | awk '{ print "local-data: \x22"$2,"AAAA ::1\x22"}'    | sort -u > /etc/unbound/blocking-data-ipv6.conf

exit 0

