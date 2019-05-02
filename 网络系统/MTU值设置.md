```
[root@e143ff54e7df /]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
7: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 02:42:ac:10:13:ca brd ff:ff:ff:ff:ff:ff
    inet 172.16.19.202/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe10:13ca/64 scope link 
       valid_lft forever preferred_lft forever
[root@e143ff54e7df /]# ifconfig eth0 mtu 1400
[root@e143ff54e7df /]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
7: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1400 qdisc noqueue state UNKNOWN 
    link/ether 02:42:ac:10:13:ca brd ff:ff:ff:ff:ff:ff
    inet 172.16.19.202/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe10:13ca/64 scope link 
       valid_lft forever preferred_lft forever

```