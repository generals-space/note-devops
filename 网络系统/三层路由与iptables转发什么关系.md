# 三层路由与iptables转发什么关系

`route`命令没有端口, iptables命令中有.

                Route
                |   |
----------------|---|---------------
                |   |
Prerouting ---->|   |----> Postrouting
做一些操作                   再做一些操作

