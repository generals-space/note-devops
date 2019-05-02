# HAProxy安装配置

参考文章

[haproxy配置文件解释(三)](http://noodle.blog.51cto.com/2925423/1795449)

[Haproxy安装及配置](http://johnsz.blog.51cto.com/525379/715922/)

HAProxy版本: 1.6.8

HAProxy与Nginx类似, 安装简单, 配置复杂且灵活, 所以文档大部分都时着眼于配置. 另外, 由于最先接触nginx, 这里将以nginx作为类比, 去解释HAProxy的配置选项.

至于应用场景, 它做的比nginx多, 可以做为ssh反向代理, 当作跳板机来用(其实就是端口转发, 不过比iptables方便多了); 还可以代理mysql, 来源限制就写在haproxy自己的配置文件里, 不必每当有一台新机器需要连接mysql时就在mysql中开放对这个IP的限制, 多麻烦.

这篇文章里只是讲了和nginx一样作为7层负载均衡的配置, 其他场景下的配置请查阅另一篇文章.

## 1. 安装

**安装依赖**

其中`pcre-devel`是为了使用正则匹配功能, `openssl-devel`是为了支持https的功能

```
$ yum install -y pcre-devel openssl-devel
```

**编译**

HAProxy的源码编译没有`configure`的过程, 源码目录下直接就有`Makefile`文件, 一些配置项是通过在使用`make`命令时设置的.

```
$ tar -zxf haproxy-1.6.8.tar.gz
$ cd haproxy-1.6.8
## 这里指定了安装目录, 开启pcre及ssl支持. 更多配置项可以参考源码包内的`README`文件
$ make PREFIX=/usr/local/haproxy TARGET=linux26 USE_PCRE=1 USE_OPENSSL=1 ADDLIB=-lz
## 将haproxy安装到指定位置
$ make install PREFIX=/usr/local/haproxy
```

## 2. 配置

这个版本的HAProxy没有提供一个默认的配置文件, 初次安装可能会不知道从何处入手. 这里提供一个最简的模板文件, 等到熟悉之后, 其余的配置项可以通过参考官方文档自行定义.

```
defaults
    # 默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK
    mode tcp
    # 采用http日志格式
    option tcplog
    # 三次连接失败就认为是服务器不可用，也可以通过后面设置
    retries 3
    # 如果cookie写入了serverId而客户端不会刷新cookie，
    # 当serverId对应的服务器挂掉后，强制定向到其他健康的服务器
    option redispatch
    # 当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接
    option abortonclose
    # 默认的最大连接数
    maxconn 4096
    balance roundrobin    #设置默认负载均衡方式，轮询方式

    # 连接超时
    timeout connect 5000
    # 客户端超时
    timeout client 30000
    # 服务器超时
    timeout server 30000
    # 心跳检测超时
    timeout check 2000

    # 注: 一些参数值为时间，比如说timeout。时间值通常单位为毫秒(ms)，但是也可以通过加#后缀，来使用其他的单位。
    #- us : microseconds.
    #- ms : milliseconds.
    #- s  : seconds.
    #- m  : minutes.
    #- h  : hours.
    #- d  : days.

global
    # 全局的日志配置 其中日志级别是[err warning info debug]
    # local0 是日志设备, 必须为如下24种标准syslog设备的一种:                     
    # kern   user   mail   daemon auth   syslog lpr    news   
    # uucp   cron   auth2  ftp    ntp    audit  alert  cron2  
    # local0 local1 local2 local3 local4 local5 local6 local7
    # 下面日志配置一节中在/etc/syslog.conf文件中定义的是local0, 所以这里也是用local0
    log 127.0.0.1 local0 info
    # 最大连接数
    maxconn 4096

    # 用户/组
    user haproxy
    group haproxy
    ## 服务模式
    daemon
    # 创建4个进程进入deamon模式运行. 此参数要求将运行模式设置为"daemon"
    nbproc 4
    # pid文件位置
    pidfile /usr/local/haproxy/var/run/haproxy.pid

########frontend配置############
## 前端访问路径, front_server1这个名字可以自定义
frontend front_server1
    # 监听端口
    bind 0.0.0.0:80
    # http的7层模式
    mode http
    # 应用全局的日志配置
    log global
    # 启用http的log
    option httplog
    # 每次请求完毕后主动关闭http通道, HA-Proxy不支持keep-alive模式
    option httpclose
    # 如果后端服务器需要获得客户端的真实IP需要配置次参数,
    # 将可以从Http Header中获得客户端IP
    option forwardfor

    ########### 日志格式 ##########
    capture request  header Host len 40
    capture request  header Content-Length len 10
    capture request  header Referer len 200
    capture response header Server len 40
    capture response header Content-Length len 10
    capture response header Cache-Control len 8

    #################### acl策略定义 #########################
    ## acl 类似于nginx的location, 也可以执行if判断
    # 如果请求的域名满足正则表达式返回true -i是忽略大小写
    acl rule1 hdr_reg(host) -i ^(www.exam.com)$

    ###################### acl策略匹配 ###################
    ## acl匹配是类似于nginx的proxy_pass命令, 就是将请求转发至后端服务器池(upstream的概念)
    # 当满足rule1的策略时使用名为 backend_pool 的 backend(后端服务器池)
    use_backend backend_pool if rule1
    #以上都不满足的时候使用默认backend_pool的backend
    default_backend backend_pool

    # HAProxy 错误页面设置
    ## 貌似不处理404错误
    errorfile 403 /usr/local/haproxy/error/403.html
    errorfile 503 /usr/local/haproxy/error/503.html

##########backend的设置##############
## 后端服务器池, nginx中的upstream概念, backend_pool这个名称可以自定义
  backend backend_pool
    # http的7层模式
    mode http
    # 负载均衡的方式, roundrobin平均方式
    balance roundrobin
    # 允许插入serverid到cookie中, serverid后面可以定义
    cookie SERVERID

    ## httpchk心跳检测的URL, haproxy将定时访问后端服务器的这个路径以确定其是否存活
    ## 'HTTP/1.1\r\nHost:XXXX', 指定了心跳检测发出的请求采用的HTTP的版本和域名
    # 在应用的检测URL对应的功能有对域名依赖的话需要设置
    option httpchk GET /index.html HTTP/1.1\r\nHost:www.exam.com

    # 服务器池定义, 'cookie 1'表示serverid为1, 'check inter 1500'是心跳检测的频率
    # rise 3是3次正确认为服务器可用, fall 3是3次失败认为服务器不可用, weight代表权重
    ## server_1, server_2这样的服务器别名是必须要写的
    server server_1 172.17.0.1:80 cookie 1 check inter 1500 rise 3 fall 3 weight 1
    server server_2 172.17.0.2:80 cookie 2 check inter 1500 rise 3 fall 3 weight 1
```

将其命名为`haproxy.cfg`, 放在`/usr/local/haproxy/etc`目录下, 默认可能没有`etc`目录, 可以手动创建. 其实配置文件的名称随意, 路径也随意, 只要在启动HAProxy时指定就好了.

上面示例文件中指定启动用户为`haproxy`, 所以先创建这个用户`useradd haproxy`.

另外, 配置文件中指定了`pid`文件, 为`/usr/local/haproxy/var/run/haproxy.pid`, 所以还需要创建`var/run`目录, 这个路径也随意, 可以在配置文件中更改, 只要HAProxy的启动用户有其写权限即可.

还有, 配置文件中指定了403, 503两个状态码的响应文件(好像`errorfile`指令不能处理404错误, 这个状态码应该不是后端服务器的响应码, 而是HAProxy本身的响应状态). 所以创建`/usr/local/haproxy/error`目录, 及`403.html`, `503.html`两个文件, 内容随意(建议内容分别写为`这是一个403错误`, `这是一个503错误`, 方便识别), 其实路径也随意, 只是在配置文件中指定到这个路径就行了.

配置文件中指定了一个访问域名`www.exam.com`, 可以通过添加`hosts`文件, 将此域名指向HAProxy所在服务器.

其中由一个`option httpchk`指令, 指定每隔一段时间, HAProxy就会访问后端服务器上的某个路径, 如果能够正常访问, 则说明后端服务器正常, 否则视其为宕机. 这里指定了访问url为`/index.html`, 所以后端服务器的80端后下还必须有`index.html`这个文件可以访问.

然后, HAProxy的启动方式是(root身份)`/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/etc/haproxy.cfg`

访问方式为`curl www.examl.com/index.html`.

------

这个配置文件的意思是, HAProxy所在的服务器监听`80`端口, 访问`www.exam.com`, HAProxy将请求转发至后端`172.17.0.1`与`172.17.0.2`两台服务器的`80`端口以实现`负载均衡`的功能.

其中, `frontend front_server1`相当于nginx中的`server`块, 可以指定端口, 域名, 转发路径等信息. 其下的`acl`策略定义及匹配则相当于nginx的`location{}`块, 并且也可以进行`if`判断与正则匹配. `use_backend`指令相当于`proxy_pass`, 将符合当前规则的请求, 转发至服务器池.

`backend backend_pool`类似于nginx的`upstream 名称`, 定义后端服务器池的名称. 可以为后端服务器设置权重及检测存活状态.

清楚了吧?

```
## 启动服务
$ /usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg
## 重启服务(没有换行)
$ /usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/etc/haproxy.cfg -st `cat /usr/local/haproxy/var/run/haproxy.pid`
## 重新加载(平滑重启, 注意haproxy没有主进程, pid文件中可能是多个进程号, 所以cat命令还是十分有必要的)
$ /usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/etc/haproxy.cfg -sf `cat /usr/local/haproxy/var/run/haproxy.pid`  
## 停止服务
$ killall haproxy
```

## 3. 高级应用

### 3.1 服务脚本

将其保存为`/etc/init.d/haproxy`文件, 并赋予可执行权限. 适用于`CentOS 6.8-`的系统(CentOS7也能凑合用...).

```
#!/bin/sh
#
# chkconfig: - 85 15 ## 运行级别、启动优先级、关闭优先级
# description: HA-Proxy is a TCP/HTTP reverse proxy which is particularly suited \
#              for high availability environments.
# processname: haproxy
# config: /usr/local/haproxy/etc/haproxy.cfg
# pidfile: /usr/local/haproxy/var/run/haproxy.pid

# Source function library.
if [ -f /etc/init.d/functions ]; then
  . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
  . /etc/rc.d/init.d/functions
else
  exit 0
fi

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

# 服务脚本名称
BASENAME=`basename $0`
if [ -L $0 ]; then
  BASENAME=`find $0 -name $BASENAME -printf %l`
  BASENAME=`basename $BASENAME`
fi

BIN=/usr/local/haproxy/sbin/$BASENAME

CFG=/usr/local/haproxy/etc/$BASENAME.cfg
[ -f $CFG ] || exit 1

PIDFILE=/usr/local/haproxy/var/run/$BASENAME.pid
LOCKFILE=/var/lock/subsys/$BASENAME

RETVAL=0

start() {
  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi

  echo -n "Starting $BASENAME: "
  daemon $BIN -D -f $CFG -p $PIDFILE
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && touch $LOCKFILE
  return $RETVAL
}

stop() {
  echo -n "Shutting down $BASENAME: "
  killproc $BASENAME -USR1
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
  [ $RETVAL -eq 0 ] && rm -f $PIDFILE
  return $RETVAL
}

restart() {
  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi
  stop
  start
}

reload() {
  if ! [ -s $PIDFILE ]; then
    return 0
  fi

  quiet_check
  if [ $? -ne 0 ]; then
    echo "Errors found in configuration file, check it with '$BASENAME check'."
    return 1
  fi
  $BIN -D -f $CFG -p $PIDFILE -sf $(cat $PIDFILE)
}

check() {
  $BIN -c -q -V -f $CFG
}

quiet_check() {
  $BIN -c -q -f $CFG
}

rhstatus() {
  status $BASENAME
}

condrestart() {
  [ -e $LOCKFILE ] && restart || :
}

# 可用方法
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  reload)
    reload
    ;;
  condrestart)
    condrestart
    ;;
  status)
    rhstatus
    ;;
  check)
    check
    ;;
  *)
    echo "Usage: $BASENAME {start|stop|restart|reload|condrestart|status|check}"
    exit 1
esac

exit $?
```

### 3.2 开启日志

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
