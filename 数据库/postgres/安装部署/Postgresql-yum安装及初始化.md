# Postgresql-yum安装及初始化

与mysql一样, 使用`yum`安装的pg也有客户端与服务端两个包, 分别是`postgresql`与`postgresql-server`.

初次安装, 需要进行初始化.

切换到`postgres`用户, 其home目录默认在`/var/lib/pgsql`. 执行`initdb`.

```
$ initdb -D data
```

`-D`参数指定数据库文件存放路径, 默认在`/var/lib/pgsql/data`. 这一步是必须的.

然后启动postgresql服务.

```
Success. You can now start the database server using:

    postgres -D /var/lib/pgsql/data
or
    pg_ctl -D /var/lib/pgsql/data -l logfile start

```

当然, `yum`装的最好通过`service`或`systemctl`命令启动.

`start`子命令是一个前端进程, 日志会在终端直接输出, 你需要使用`-l`指定一个日志文件, 就可以以服务的形式运行postgres了.

## 配置

默认pg只允许本机访问, 如果需要打开外网监听, 需要修改`pg_hba.conf`, 通过yum安装的pg, 这个文件在`/var/lib/pgsql/data`目录下.

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
host    all             all             0.0.0.0/0                 md5 
```

本机信任(trust), 其他所有机器可以MD5验证连接, 其实就是普通用户名密码形式.

哦, 还有, `postgresql.conf`的`listen_addresses`默认是`localhost`, 记得改成'*'表示监听所有连接.

> `pg_hba.conf`修改后, 使用`pg_ctl reload`重新读取`pg_hba.conf`文件, 如果`pg_ctl`找不到数据库, 则用`-D /.../pgsql/data/`指定数据库目录, 或`export PGDATA=/.../pgsql/data/`导入环境变量.