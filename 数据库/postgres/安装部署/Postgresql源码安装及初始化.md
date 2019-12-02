# Postgresql源码安装及初始化

参考文章

1. [Linux CentOS 7源码编译安装PostgreSQL9.5](http://www.jb51.net/article/97923.htm)

下载源码包, 解压.

安装依赖包

```
$ yum install gcc readline-devel zlib-devel
```

配置选项

```
$ ./configure --prefix=/opt/pgsql9.5.9
```

编译安装

```
$ make && make install 
```

编译安装成功后, 接下来要做的就是创建一个普通用户, 因为**默认超级用户（root）不能启动postgresql**, 所以需要创建一个普通用户来启动数据库, 执行以下命令创建用户

```
$ useradd postgres
```

我们要用这个用户初始化数据目录, 配置文件等. 首先创建环境变量配置, 初始化数据目录要用的.

```bash
## 这个是源码安装pg的目标目录, 即configure的`--prefix`参数
export PGHOME=/opt/pgsql9.5.9
## 数据, 配置文件存储目录
export PGDATA=/opt/pgdata
export PGHOST=$PGDATA
export LANG=en_US.utf8
export LD_LIBRARY_PATH=$PGHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib
export DATE=`date +"%Y%m%d%H%M"`
export PATH=$PGHOME/bin:$PATH:.
export MANPATH=$PGHOME/share/man:$MANPATH
```

环境变量生效后就可以执行`initdb`命令了, 初始化完成后会提示启动命令的. 一般执行`pg_ctl start`就可以了. 不过暂时先不要启动, 有点配置还需要修改.

`/opt/pgdata/postgres.conf`文件

`listen_addresses`默认是`localhost`, 记得改成'*'表示监听所有连接.

`port`默认为5432, 可自定义.

`unix_socket_directory`或`unix_socket_directories`这个是定义本地连接`.sock`文件的路径的, 默认是`/tmp`, 源码安装时需要将其修改成'.', 否则psql连接时会报如下错误.

```
$ psql 
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/opt/pgdata/.s.PGSQL.5432"?
```

然后是`/opt/pgdata/hba.conf`, 这是身份验证的配置文件, 默认只允许本地连接, 如下.

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
```
要开启远程连接的话需要添加一行

```
host    all             all             0.0.0.0/0                 md5
```

其中`trust`表示直连不需要密码, `md5`则是正常的用户名密码的连接方式.