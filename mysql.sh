#!/bin/bash
tar -xf mysql-5.7.17.tar 
yum -y install mysql-community-* &> /dev/null
systemctl start mysqld
systemctl enable mysqld  &> /dev/null
passwd=`grep 'password' /var/log/mysqld.log  | awk '{print $11}'`
mysql -uroot -p"$passwd"
