# Rsyslog使用配置

参考文章

[Linux配置syslog服务器及CentOS配置rsyslog客户端远程记录日志](http://www.111cn.net/sys/CentOS/81133.htm)

[CHAPTER 20. VIEWING AND MANAGING LOG FILES](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/ch-Viewing_and_Managing_Log_Files.html)

...嗯, rsyslog的官方文档真差劲, 不如直接看redhat对rsyslog的介绍.

## 1. 前言

听说rsyslog是syslog的升级版, 用来收集系统日志的. 可以使用这个服务部署集中化的日志管理中心, 客户端将系统日志发送到rsyslog服务器上, 也可以防止客户端系统故障导致无法查看日志的情况.

不过这么说来rsyslog应用场景限制蛮大的, 像mysql, nginx等应用软件都是自己定义并生成日志文件, 用不上; 能用上的一般是系统级别的信息, 比较登录验证信息(`/var/log/secure`), crontab调度信息(`/var/log/cron`)等.

不过也有一些应用软件懒得自行编写日志模块, 直接调用rsyslog服务的, 比如haproxy, supervisord等. 这里分析一下调用rsyslog的方式, 日志级别/格式等方法.

## 2. rsyslog安装方法

## 3. 配置

haproxy-1.6.8中将日志发送给rsyslog服务需要如下配置

```
log 127.0.0.1 local0 info
```

对应rsyslog的配置中要配置如下字段

```
$ModLoad imudp
$UDPServerRun 514
...
local0.*                                /var/log/haproxy.log
```

其中haproxy配置的`log`字段, `127.0.0.1`指定了rsyslog服务器的地址, `local0`在rsyslog中被称为"设施(facility)", 之后的`info`指的是日志级别(这个很好理解吧).

由于haproxy默认连接rsyslog服务器的514端口(UDP协议), 所以rsyslog需要解开`imudp`模块的注释, 否则它只通过sock文件接收本地的系统日志信息. 其中的`local0`对应haproxy配置是的`local0`, 后面的`.*`表示所有的日志级别, 最后就是日志文件的路径了.

猜测应该可以像nginx一样, 将普通info级别与erro级别的信息写在不同的日志文件中.

```
local0.err                              /var/log/haproxy_err.log
local0.*                                /var/log/haproxy.log
```

------

首先来认识一下rsyslog中"设施"的概念(这个翻译不准确, 译成"平台"还可以, 还不如直接用`facility`). 在rsyslog中有如下默认配置

```
# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog
# crontab进程或应用调度相关的消息
cron.*                                                  /var/log/cron
# Everybody gets emergency messages
*.emerg                                                 *
# Save news errors of level crit and higher in a special file.
uucp,news.crit                                          /var/log/spooler
```

设施表示了linux对内部系统进程进行分类的方法, 其中`authpriv`身份验证相关的消息(登录时), 所有登录行为, 包括终端, ssh远程登录等都会将日志发送到这个设施. 进程调用rsyslog服务时需要显式指定目标设施信息.

上述haproxy配置中指定的设施为`local0`, 这个是rsyslog提供给用户的自定义设施类型, 一共有`local0`-`local7`8个(`local7`通常被Cisco和Windows服务器使用), 不多, 但调用rsyslog的应用级别程序也没多少...

redhat官网的参考文章中给出了19种平台选项, 9种日志级别, 这里不再一一列出.

## 4. 调用方法

linux平台下rsyslog服务也可以作为客户端, 将本机的系统日志发送到远程rsyslog服务器上. 需要作为客户端上也安装并开启rsyslog服务, 并有如下配置.

```
*.* @192.168.1.1:514
```

其中`192.168.1.1`与`514`分别是目标rsyslog服务器的IP与端口(UDP). 如果目标服务器的rsyslog监听的端口为TCP类型, 你需要修改成如下

```
*.* @@192.168.1.1:514
```

嗯, 多了一个`@`字符.

如果你只想要转发服务器上的指定设备的日志消息，比如说内核设备，那么你可以在rsyslog配置文件中使用以下声明。

```
kern.* @192.168.1.25:514 
```

## FAQ

### 1. 自定义日志路径无法输出

问题描述

`local0`级别的日志路径设置在`/var/log/haproxy.log`可以自动生成, 但是配置成`/root/haproxy.log`就不行.

原因在于SELinux, 关掉就行了.

[参考文章](http://bbs.csdn.net/topics/390794010)