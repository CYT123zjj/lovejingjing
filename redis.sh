#!/bin/bash
aa=`ifconfig eth0 | sed -n '2p' | awk '{print $2}'`
a=`echo ${aa##*.}`
b=$[a+6300]
cd /redis/
yum -y install gcc
tar -zxvf redis-4.0.8.tar.gz
cd redis-4.0.8
make && make install
echo | ./utils/install_server.sh
#redis基础配置
sed -i "70 s/bind 127.0.0.1/bind $aa/" /etc/redis/6379.conf
sed -i "93 s/port 6379/port $b/" /etc/redis/6379.conf
#sed -i '$a requirepass 123456' /etc/redis/6379.conf
sed -i  '43c  $CLIEXEC -h '"$aa"'  -p '"$b"' -a 123456  shutdown' /etc/init.d/redis_6379
#集群配置
sed -i '829 s/15000/5000/;829 s/#//' /etc/redis/6379.conf
sed -i '823 s/#//' /etc/redis/6379.conf 
sed -i '815 s/#//' /etc/redis/6379.conf

redis-cli -h 127.0.0.1 shutdown
/etc/init.d/redis_6379  start
/etc/init.d/redis_6379  restart
 netstat -utnlp  | grep redis-server

