#!/bin/bash
for i in `cat $1`
do
 scp -r /linux-soft/03/redis  root@192.168.4.$i:/
 scp -r 桌面/redis.sh  root@192.168.4.$i:/
 ssh  root@192.168.4.$i  "bash /redis.sh"
sleep 2
done

