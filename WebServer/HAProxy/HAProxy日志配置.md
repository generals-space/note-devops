# HAProxy日志配置

假设日志服务为`syslog`或`rsyslog`(后者是前者的增强版, 作用, 配置文件几乎相同), 这里以`rsyslog`为例. `HAProxy`不像`Nginx`与`Apache`, 没有办法自行创建并写入日志文件. 它需要调用`rsyslog`服务, 将日志信息发送给`rsyslog`, 并由`rsyslog`管理其日志.

我们需要做的, 首先, 在`HAProxy`本身的配置文件`haproxy.cft`中添加

```
defaults
    # 采用http日志格式
    option httplog
...
global
   log 127.0.0.1 local0 info
...
frontend front_server1
    # 应用全局的日志配置
    log global
```

其中`option`指令指定日志格式, 有`tcplog`,`httplog`等; `log`指令指定日志级别, `local0`是`rsyslog`服务开放给自定义服务的日志类型, 包括`local0`-`local7`8种类型, `info`是记录的日志级别.

然后编辑`/etc/rsyslog.conf`文件, 修改成如下:

```
# Provides UDP syslog reception
## 解开以下行的注释, 不然日志文件会创建但没有日志输出
$ModLoad imudp
$UDPServerRun 514
...

## 这里的local0与haproxy中的`local0`相对应.
local0.*        /var/log/haproxy.log
```

因为UDP 514是Linux系统默认的`syslog`使用的端口(在`/etc/service`中可查看), 重启`rsyslog`与`haproxy`服务, 可以看到有日志产生.
