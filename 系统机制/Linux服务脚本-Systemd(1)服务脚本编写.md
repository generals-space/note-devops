CentOS7环境下的脚本位置在`/usr/lib/systemd/system/php-fpm.service`, 其内容为

[官方文档](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

```
[Unit]
Description=The PHP FastCGI Process Manager
After=syslog.target network.target                                     

[Service]
Type=notify
PIDFile=/run/php-fpm/php-fpm.pid
EnvironmentFile=/etc/sysconfig/php-fpm
ExecStart=/usr/sbin/php-fpm daemonize
ExecReload=/bin/kill -USR2 $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 源码分析

## 认知

1. 理论上讲, 任何程序都可以交由`systemd`管理(...就算随便写一个hello world的脚本也可以).

2. 由systemd管理的程序, 其标准输出及标准错误都会被systemd内置的日志记录工具`journald`记录下来, 可以通过`journalctl --unit 服务名`查看.

3. `Requires`与`Wants`这种依赖关键字, 只是明确指出依赖关系, 不会自动启动被依赖的服务, 如果A依赖B, B未启动, 那启动A时只会报错而不会自动帮我们启动B.

## 1. 变量定义

在`.service`文件中在`[service]`块中使用`Environment`字段可以定义单个变量, 格式如下

```
Environment=变量名=变量值
```

也可以使用`EnvironmentFile`字段指定一个变量定义文件, 然后把所以的变量写在这个文件里, 格式如下

```
EnvironmentFile=变量文件绝对路径
```

变量文件中的也是`变量名=变量值`的格式, 一行一条.

#### 1.

使用`Environment`定义的变量, **变量值中不可以有空格**, 我曾经尝试过使用单双引号将包含空格的变量值包裹起来, 但会报错(引用这个变量的时候才会).

```
## 正确
Environment=OPTS=--pid=/tmp/fpm.pid
## 错误, 不能有空格, 并且不能写多条, 长选项可以使用'='连接, 短选项可以合并到一起写
Environment=OPTS=--pid /tmp/fpm.pid
```

使用`EnvironmentFile`在变量定义文件中, 变量值可以有空格, 并且可以多个选项写在同一行, 如

```
OPTS=--pid /tmp/hehe.pid --daemonize
```

则`.service`文件中可以这样使用

```
ExecStart=/usr/local/php/sbin/php-fpm $OPTS
```

#### 2.

引用一个不存在的变量不会报错, 但引用一个不存在的变量配置文件会报`Failed to load environment files: No such file or directory`. 有时不确定是不是存在这样的变量配置文件, 需要在`EnvironmentFile`的值前面加上`-`中划线**抑制错误**, 就算不存在这个文件也不会出错停止.

```
EnvironmentFile=-变量文件绝对路径
```

#### 3.

`.service`文件中类似于`ExecStart`的字段(其实应该是大多数字段)第1个参数应该是一个可执行文件的绝对路径, **必须是绝对路径, 存在于环境变量也不行, 并且不能包含任何变量**.

如果在环境变量文件中有如下定义

```
PREFIX=/usr/local/php
```

而在`.service`文件中希望像下面这样使用是不可以的, `systemd`无法解析出这个变量, 将会启动失败.

```
ExecStart=$PREFIX/sbin/php-fpm --nodaemonize
```

另外, 环境变量配置文件中也无法引用其他变量, 例如

```
PID=/tmp/php-fpm.pid
OPTS=--daemonize --pid $PID
```

在`.service`文件打算这样使用

```
ExecStart=/usr/local/php/sbin/php-fpm $OPTS
```

并不能达到预期的效果, `systemd`没有办法解析`$OPTS`, 它将把'$OPTS'字符串当作PID文件名, 然后在默认路径下创建了名为'$OPTS'的PID文件...

所以在变量配置文件中也不能随意进行变量引用, 还不如不用, 只能写全路径.

> 对systemd服务脚本进行修改后, 需要使用`systemctl daemon-reload`使其生效.