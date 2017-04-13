
## image 创建

glance image-create --name "yardstick-trusty-server"  \
    --file /opt/yardstick-trusty-server.img \
    --disk-format qcow2 --container-format bare --is-public True

glance image-create --name "cirros-0.3.3"  \
    --file /home/opnfv/images/cirros-0.3.3-x86_64-disk.img \
    --disk-format qcow2 --container-format bare

glance image-create --name "cirros-0.3.3"  \
    --file /home/opnfv/images/cirros-0.3.3-x86_64-disk.img \
    --disk-format qcow2 --container-format bare \
    --visibility public

[root@host3 ~]# glance image-show fa682b3a-48d0-4b77-af54-634eb9fd154f
+------------------+--------------------------------------------------------------------+
| Property         | Value                                                              |
+------------------+--------------------------------------------------------------------+
| checksum         | 133eae9fb1c98f45894a4e60d8736619                                   |
| container_format | bare                                                               |
| created_at       | 2016-04-20T19:46:32Z                                               |
| direct_url       | file:///var/lib/glance/images/fa682b3a-48d0-4b77-af54-634eb9fd154f |
| disk_format      | qcow2                                                              |
| id               | fa682b3a-48d0-4b77-af54-634eb9fd154f                               |
| min_disk         | 0                                                                  |
| min_ram          | 0                                                                  |
| name             | cirros-0.3.3                                                       |
| owner            | a4edb706be154ccdbbe531637435e0be                                   |
| protected        | False                                                              |
| size             | 13200896                                                           |
| status           | active                                                             |
| tags             | []                                                                 |
| updated_at       | 2016-04-23T17:04:40Z                                               |
| virtual_size     | None                                                               |
| visibility       | public                                                             |
+------------------+--------------------------------------------------------------------+

## flavor 创建

nova flavor-create yardstick-flavor 6 2048 10 2

nova flavor-create m1.tiny 1 1024 0 1

## 虚拟网络创建

ifconfig br-ex 172.16.9.1/24

neutron net-create net04_ext --router:external 
neutron subnet-create net04_ext 172.16.9.0/24 --name net04_ext__subnet --allocation-pool start=172.16.9.130,end=172.16.9.254 --disable-dhcp --gateway 172.16.9.1

neutron router-create demo-router
neutron router-gateway-set demo-router net04_ext

neutron net-create demo-net
neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1
neutron router-interface-add demo-router demo-subnet

; neutron net-create ext-net --router:external   --provider:physical_network physnet --provider:network_type vlan --provider:segmentation_id 1

neutron net-create ext-net --router:external --provider:physical_network physnet --provider:network_type flat


; for 192.168.50.13 odl
### compass 网络的创建

neutron net-create ext-net --provider:network_type=flat --provider:physical_network physnet --router:external=true
neutron subnet-create ext-net 192.168.50.0/24 --name ext-subnet --enable-dhcp=False --allocation-pool start=192.168.50.199,end=192.168.50.210 --gateway 192.168.50.1



neutron net-create ext-net --provider:network_type=flat --provider:physical_network physnet --router:external=true
neutron subnet-create ext-net 192.168.108.0/24 --name ext-subnet --enable-dhcp=False --allocation-pool start=192.168.108.123,end=192.168.108.131 --gateway 192.168.108.1

openstack network create  --share \
  --provider-physical-network flat \
  --provider-network-type flat provider

### compass4nfv openstack use public endpoint

export OS_INTERFACE=public

## 安全组配置

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

$ nova secgroup-list-rules open
+-------------+-----------+---------+-----------+--------------+
| IP Protocol | From Port | To Port | IP Range  | Source Group |
+-------------+-----------+---------+-----------+--------------+
| icmp        | -1        | 255     | 0.0.0.0/0 |              |
| tcp         | 1         | 65535   | 0.0.0.0/0 |              |
| udp         | 1         | 65535   | 0.0.0.0/0 |              |
+-------------+-----------+---------+-----------+--------------+

nova secgroup-add-rule rubbos-security-group tcp 1 65535 0.0.0.0/0
nova secgroup-add-rule rubbos-security-group udp 1 65535 0.0.0.0/0
nova secgroup-add-rule rubbos-security-group icmp -1 -1 0.0.0.0/0

sudo python -m SimpleHTTPServer 80


## floating ip 配置

neutron floatingip-create net04_ext
nova floating-ip-associate demo-instance1 172.16.9.131 

## 虚拟机启动

nova boot --flavor m1.tiny --image cirros-0.3.3 \
    --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') \
    --security-group default demo1

nova boot --flavor 1 --image 1891a9e0-b2b8-4a3b-8b3f-e6cd2eaeb554 --security-groups default --key-name demo-key --nic net-id=5d591a46-4a7e-4408-b8d7-db3a8c54de25 myvm

nova boot --flavor 1 --image 4943d1df-7b38-4c6c-a63a-0f26a6fe3d56 --nic net-id=f883bc7d-badb-434d-bc18-1622f369b1b7 --nic net-id=76dea593-1c1e-417f-84a9-1a6be0297ec1 --availability-zone :host5 test2

## nova keypair
nova keypair-add --pub-key yardstick_key.pub yardstick-key

nova keypair-list

## qcow2 image resize

qemu-img resize foo.qcow2 +32G

## console log

nova console-log vRouter

## netns check host location

neutron dhcp-agent-list-hosting-net  bottlenecks-private 

## centos

http://docs.openstack.org/mitaka/install-guide-rdo

/bin/systemctl -l
/bin/systemctl restart openstack-nova-compute.service

  openstack-nova-api.service
  openstack-nova-consoleauth.service
  openstack-nova-scheduler.service
  openstack-nova-conductor.service
  openstack-nova-novncproxy.service

# systemctl enable libvirtd.service openstack-nova-compute.service
# systemctl start libvirtd.service openstack-nova-compute.service


## VM Migration

nova migrate demo1
nova resize-confirm demo1

## VM Live-Migration

nova live-migration <vm-id> <dest-host-name>

---

## 装好的 compass 上手动运行 cirros 实例

source /opt/admin-openrc.sh


neutron net-create ext-net --provider:network_type=flat --provider:physical_network physnet --router:external=true
neutron subnet-create ext-net 192.168.108.0/24 --name ext-subnet --enable-dhcp=False --allocation-pool start=192.168.108.121,end=192.168.108.131 --gateway 192.168.108.1


wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

glance image-create --name "cirros-0.3.3" --file cirros-0.3.4-x86_64-disk.img  --disk-format qcow2 --container-format bare

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

neutron router-create demo-router
neutron router-gateway-set demo-router ext-net
neutron net-create demo-net
neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1
neutron router-interface-add demo-router demo-subnet


nova boot --flavor m1.tiny --image cirros-0.3.3     --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') demo1


nova boot --flavor m1.tiny --image cirros-0.3.3     --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}')     --security-group default demo1

neutron floatingip-create ext-net
nova floating-ip-associate demo1 192.168.21.223

ssh cirros@192.168.21.223

## 清理

neutron router-gateway-clear demo-router
neutron router-interface-delete demo-router demo-subnet
neutron subnet-delete demo-subnet
neutron subnet-delete ext-subnet
neutron net-delete demo-net
neutron net-delete ext-net
neutron router-delete demo-router

## [Select hosts where instances are launched](http://docs.openstack.org/admin-guide/cli-nova-specify-host.html)

nova boot --flavor m1.tiny --image cirros-0.3.3 --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') --availability-zone nova:host7:host7 demo

openstack server create --image IMAGE --flavor m1.tiny \
  --key-name KEY --availability-zone ZONE:HOST:NODE \
  --nic net-id=UUID SERVER

openstack availability zone list
openstack host list
openstack hypervisor list

nova boot --flavor m1.tiny --image cirros-0.3.3 --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') --availability-zone nova:host4:host4 demo


---


## live-migration testing

https://blog.zhaw.ch/icclab/an-analysis-of-the-performance-of-live-migration-in-openstack/

## 冷热迁移 test

```bash
nova flavor-create m1.tiny 1 1024 0 1


neutron net-create ext-net --provider:network_type=flat --provider:physical_network physnet --router:external=true
neutron subnet-create ext-net 192.168.108.0/24 --name ext-subnet --enable-dhcp=False --allocation-pool start=192.168.108.221,end=192.168.108.231 --gateway 192.168.108.1


scp 10.1.0.12:/var/www/guestimg/cirros-0.3.3-x86_64-disk.img ~/

source /opt/admin-openrc.sh

glance image-create --name "cirros-0.3.3"  \
    --file /root/cirros-0.3.3-x86_64-disk.img \
    --disk-format qcow2 --container-format bare

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

neutron router-create demo-router
neutron router-gateway-set demo-router ext-net
neutron net-create demo-net
neutron subnet-create demo-net 192.168.1.0/24 --name demo-subnet --gateway 192.168.1.1
neutron router-interface-add demo-router demo-subnet

nova boot --flavor m1.tiny --image cirros-0.3.3     --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') demo1


neutron floatingip-create ext-net
nova floating-ip-associate demo1 192.168.108.222

ssh cirros@192.168.108.222


openstack volume create --image e6c5e953-90b8-4bdb-9f2a-5ae68f6a68af --size 1 bootable_volume
openstack server create --flavor m1.tiny --volume 572ea567-933d-42ba-a12c-81c7586d7d4f --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') demo1


openstack server create --flavor disk --volume 79e53594-4a1d-4b20-bb67-645908da9e53 --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') demo2



nova boot --flavor m1.tiny --image cirros-0.3.3     --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') demo1




nova migrate demo1
nova resize-confirm demo1

```

## Boot Xenial VM

```bash
wget 192.168.21.2:8888/xenial-server-cloudimg-amd64-disk1.img
glance image-create --name "xenial"  \
    --file /root/xenial-server-cloudimg-amd64-disk1.img \
    --disk-format qcow2 --container-format bare

nova keypair-add --pub-key /root/.ssh/id_rsa.pub mykey

nova boot --flavor m1.small --image xenial --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') --key-name mykey demo2

nova boot --flavor m1.tiny --image cirros-0.3.3 --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') --availability-zone nova:host4:host4 demo

nova boot --flavor m1.tiny --image cirros-0.3.3 --nic net-id=$(neutron net-list | grep demo-net | awk '{print $2}') --availability-zone nova:host5:host5 demo
```

