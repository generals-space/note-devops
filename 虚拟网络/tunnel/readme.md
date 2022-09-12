ipip, gre是实现隧道的两种模式.

添加tunnel设备时需要按照一定的格式, 否则会出错. 以下列出了几种可能的格式.

- [x] ip tunnel add tun_ipip0 mode ipip remote 8.210.37.47 local 172.16.156.195
- [x] ip tunnel add tun_ipip0 mode ipip local 172.16.156.195
- [ ] ip tunnel add tun_ipip0 mode ipip local 0.0.0.0
- [ ] ip tunnel add tun_ipip0 mode ipip
