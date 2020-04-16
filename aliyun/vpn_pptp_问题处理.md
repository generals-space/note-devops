参考文章

1. [[PPTPD]VPN解决PTY read or GRE write failed问题](https://www.lidaren.com/archives/1229)

```
Apr 15 00:09:11 wuhou pppd[30788]: Using interface ppp0
Apr 15 00:09:11 wuhou pppd[30788]: Connect: ppp0 <--> /dev/pts/1
Apr 15 00:09:40 wuhou pppd[30788]: Modem hangup
Apr 15 00:09:40 wuhou pppd[30788]: Connection terminated.
Apr 15 00:09:40 wuhou pppd[30788]: Exit.
Apr 15 00:09:40 wuhou pptpd[30786]: CTRL: Client 60.186.190.223 control connection finished
```

换了 windows.

```
Apr 15 00:21:37 wuhou pppd[31452]: Using interface ppp0
Apr 15 00:21:37 wuhou pppd[31452]: Connect: ppp0 <--> /dev/pts/1
Apr 15 00:22:07 wuhou pppd[31452]: LCP: timeout sending Config-Requests
Apr 15 00:22:07 wuhou pppd[31452]: Connection terminated.
Apr 15 00:22:07 wuhou pppd[31452]: Modem hangup
Apr 15 00:22:07 wuhou pppd[31452]: Exit.
Apr 15 00:22:07 wuhou pptpd[31451]: GRE: read(fd=6,buffer=56538df2a480,len=8196) from PTY failed: status = -1 error = Input/output error, usually caused by unexpected termination of pppd, check option syntax and pppd logs
Apr 15 00:22:07 wuhou pptpd[31451]: CTRL: PTY read or GRE write failed (pty,gre)=(6,7)
Apr 15 00:22:07 wuhou pptpd[31451]: CTRL: Client 60.186.190.223 control connection finished
```

修改服务端的`/etc/pptpd.conf`文件, 注释掉`logwtmp`字段.


iptables -I FORWARD -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1396

iptables -A INPUT -p gre -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 47 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 1723 -j ACCEPT