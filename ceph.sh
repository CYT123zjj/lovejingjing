#!/bin/bash
echo -e "192.168.4.10  client\n192.168.4.11     node1\n192.168.4.12     node2\n192.168.4.13     node3" >> /etc/hosts
 for i in client node1  node2  node3 
do
scp  /etc/hosts   $i:/etc/ &> /dev/null
done
echo -e "[mon]\nname=mon\nbaseurl=ftp://192.168.4.254/ceph/MON\ngpgcheck=0\n[osd]\nname=osd\nbaseurl=ftp://192.168.4.254/ceph/OSD\ngpgcheck=0\n[tools]\nname=tools\nbaseurl=ftp://192.168.4.254/ceph/Tools\ngpgcheck=0" > /etc/yum.repos.d/ceph.repo
for i in  client  node1  node2  node3
do
scp  /etc/yum.repos.d/ceph.repo   $i:/etc/yum.repos.d/ &> /dev/null
done
sed -i '/server gateway/s/gateway/192.168.4.254/' /etc/chrony.conf
for i in client  node1  node2  node3
do
 scp /etc/chrony.conf $i:/etc/ &> /dev/null
ssh  $i  "systemctl restart chronyd"  &> /dev/null
done
yum -y install ceph-deploy &> /dev/null
mkdir ceph-cluster
cd ceph-cluster/
for i in node1 node2 node3
do
ssh  $i "yum -y install ceph-mon ceph-osd ceph-mds ceph-radosgw" &> /dev/null
done
cd ceph-cluster/
ceph-deploy new node1 node2 node3 
ceph-deploy mon create-initial 
for i in node1 node2 node3
do
 ssh $i "parted /dev/vdb mklabel gpt" &> /dev/null
     ssh $i "parted /dev/vdb mkpart primary 1 50%" &> /dev/null
     ssh $i "parted /dev/vdb mkpart primary 50% 100%" &> /dev/null
done
for i in node{1..3}
do
ssh $i "chown  ceph.ceph  /dev/vdb1"
ssh $i "chown  ceph.ceph  /dev/vdb2"
done
echo 'ENV{DEVNAME}=="/dev/vdb1",OWNER="ceph",GROUP="ceph"' >> /etc/udev/rules.d/70-vdb.rules
echo 'ENV{DEVNAME}=="/dev/vdb2",OWNER="ceph",GROUP="ceph"' >> /etc/udev/rules.d/70-vdb.rules
for i in node{1..3}
do
scp /etc/udev/rules.d/70-vdb.rules $i:/etc/udev/rules.d/70-vdb.rules &> /dev/null
done
cd ceph-cluster/
ceph-deploy disk  zap  node1:vdc   node1:vdd &> /dev/null
ceph-deploy disk  zap  node2:vdc   node2:vdd &> /dev/null
ceph-deploy disk  zap  node3:vdc   node3:vdd &> /dev/null
ceph-deploy osd create node1:vdc:/dev/vdb1 node1:vdd:/dev/vdb2 &> /dev/null
ceph-deploy osd create  node2:vdc:/dev/vdb1 node2:vdd:/dev/vdb2 &> /dev/null
ceph-deploy osd create node3:vdc:/dev/vdb1 node3:vdd:/dev/vdb2 &> /dev/null
systemctl restart ceph\*.service ceph\*.target
systemctl restart 
ceph -s
