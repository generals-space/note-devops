# denyhosts防止ssh爆破

参考文章

1. [DenyHosts使用](https://blog.51cto.com/14043491/2309673)
    - 同类产品
2. [DenyHosts安装及配置](https://www.cnblogs.com/lcword/p/5912625.html)3
3. [DenyHosts - AttributeError: 'module' object has no attribute 'ListType'](https://github.com/denyhosts/denyhosts/issues/54)

DenyHosts是一个python写的脚本, 常用来限制SSH登陆, 通过监控系统日志(`/var/log/secure`), 将超过错误次数的IP放入TCP Wrappers中禁止登陆. UNIX Review杂志评选的2005年8月的月度工具. 除了基础的屏蔽IP功能, 还有邮件通知, 插件, 同步等功能. 

[官方站点](http://denyhosts.sourceforge.net/)

[GitHub代码](https://github.com/denyhosts/denyhosts)

## 安装

- OS: CentOS 7.7
- python版本: 3.6
- denyhosts版本: 3.1 Beta

denyhost貌似没有yum/apt包, 但在github上有release包, 所以一般是通过源码安装的.

denyhost依赖于`ipaddr`模块, 所以要使用pip先装上此依赖.

```
python3 setup.py install
```

安装完成后, 配置文件在`/etc/denyhosts.conf`, 其实无需拷贝, 当然源码目录中也有备份.

但是需要做一些修改, 由于不同系统记录ssh行为的文件不相同(ubuntu下是`/var/log/auth.log`, centos是`/var/log/secure`), 默认配置为Ubuntu, 这样启动时会由于找不到记录文件而失败退出. 我当前正在配置见本文件同目录的`denyhosts.conf`

`service`服务脚本也在源码目录中, 不过`systemctl start denyhosts`启动会失败, 查看message有如下日志

```
Dec  8 21:29:02 wuhou systemd: Starting SSH log watcher...
Dec  8 21:29:02 wuhou systemd: Failed at step EXEC spawning /usr/bin/denyhosts.py: No such file or directory
Dec  8 21:29:02 wuhou systemd: denyhosts.service: control process exited, code=exited status=203
Dec  8 21:29:02 wuhou systemd: Failed to start SSH log watcher.
Dec  8 21:29:02 wuhou systemd: Unit denyhosts.service entered failed state.
Dec  8 21:29:02 wuhou systemd: denyhosts.service failed.
```

我查了下, 果然`/usr/bin/denyhosts.py`文件不存在, 然后又查了下, 发现这个文件在`/usr/local/bin/denyhosts.py`. 

于是我创建了个软链接

```
ln -s /usr/local/bin/denyhosts.py /usr/bin/denyhosts.py
```

但是启动还是有问题, 看起来像是代码的问题.

```
Dec  8 22:08:38 wuhou systemd: Starting SSH log watcher...
Dec  8 22:08:52 wuhou denyhosts.py: Traceback (most recent call last):
Dec  8 22:08:52 wuhou denyhosts.py: File "/usr/bin/denyhosts.py", line 229, in <module>
Dec  8 22:08:52 wuhou denyhosts.py: first_time, noemail, daemon, foreground)
Dec  8 22:08:52 wuhou denyhosts.py: File "/usr/local/lib/python3.6/site-packages/DenyHosts/deny_hosts.py", line 78, in __init__
Dec  8 22:08:52 wuhou denyhosts.py: offset = self.process_log(logfile, last_offset)
Dec  8 22:08:52 wuhou denyhosts.py: File "/usr/local/lib/python3.6/site-packages/DenyHosts/deny_hosts.py", line 501, in process_log
Dec  8 22:08:52 wuhou denyhosts.py: self.__report.add_section(msg, new_denied_hosts)
Dec  8 22:08:52 wuhou denyhosts.py: File "/usr/local/lib/python3.6/site-packages/DenyHosts/report.py", line 43, in add_section
Dec  8 22:08:52 wuhou denyhosts.py: if (type(i) is types.ListType) or (type(i) is types.TupleType):
Dec  8 22:08:52 wuhou denyhosts.py: AttributeError: module 'types' has no attribute 'ListType'
Dec  8 22:08:52 wuhou denyhosts.py: DenyHosts exited abnormally
Dec  8 22:08:52 wuhou systemd: Can't open PID file /var/run/denyhosts.pid (yet?) after start: No such file or directory
Dec  8 22:08:52 wuhou systemd: Failed to start SSH log watcher.
Dec  8 22:08:52 wuhou systemd: Unit denyhosts.service entered failed state.
Dec  8 22:08:52 wuhou systemd: denyhosts.service failed.
```

按照参考文章2中所说, 修改`site-packages/DenyHosts/report.py`文件

```
            ## if (type(i) is types.ListType) or (type(i) is types.TupleType):
            if isinstance(i, list) or isinstance(i, tuple):
```

然后可以成功运行.
