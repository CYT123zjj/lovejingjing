#!/bin/bash
#在解压包lnmp_soft目录下操作
conf="/usr/local/nginx/conf/nginx.conf"

yum -y install gcc openssl-devel pcre-devel

useradd -s /sbin/nologin nginx

tar -xf nginx-1.12.2.tar.gz

cd nginx-1.12.2

 ./configure  --user=nginx  --group=nginx  --with-http_stub_status_module  --with-stream   --with-http_ssl_module

make && make install

yum -y install mariadb mariadb-server mariadb-devel

yum -y install php php-fpm php-mysql

sed -i  '65,72s/#//' $conf

sed -i  '/SCRIPT_FILENAME/s/^/#/' $conf

sed -i  's/fastcgi_params/fastcgi.conf/' $conf

systemctl start mariadb

systemctl enable mariadb

systemctl start  php-fpm

systemctl enable php-fpm

/usr/local/nginx/sbin/nginx

ss -unptl
