# saltstack-minion安装步骤

## 环境搭建

上传python-2.7.12.tgz源码包 get-pip.py脚本到/tmp目录下

```
yum install -y python-devel openssl-devel sqlite-devel gcc gcc-c++
```

```
http://192.168.160.200/yum/epel/5/i386/repodata/911626d621760eaa5b618486c14958f30075e2c3-filelists.sqlite.bz2: [Errno 14] HTTP Error 404: Not Found
Trying other mirror.
Error: failure: repodata/911626d621760eaa5b618486c14958f30075e2c3-filelists.sqlite.bz2 from epel: [Errno 256] No more mirrors to try.
 You could try using --skip-broken to work around the problem
 You could try running: package-cleanup --problems
                        package-cleanup --dupes
                        rpm -Va --nofiles --nodigest
The program package-cleanup is found in the yum-utils package.
```

出现这种, 先`yum clean all`再装.

如果装sqlite-devel有依赖问题, 可以不装. 一般centos 5.x才会出现这个问题

解压`Python-2.7.12.tgz`, 编辑`Python-2.7.2/Modules/Setup.dist`, 解开下面的注释 

```
SSL=/usr/local/ssl
_ssl _ssl.c \
        -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
        -L$(SSL)/lib -lssl -lcrypto
```

```
./configure --prefix=/usr/local/python2.7
make && make install
```

把/usr/local/python2.7/bin加入PAHT环境变量

```
vim /etc/profile
export PATH=$PATH:/usr/local/python2.7/bin
```

安装pip

```
source /etc/profile
python2.7 /tmp/get-pip.py 
```

如果遇到如下问题

```
Collecting pip
  Retrying (Retry(total=4, connect=None, read=None, redirect=None)) after connection broken by 'NewConnectionError('<pip._vendor.requests.packages.urllib3.connection.VerifiedHTTPSConnection object at 0x7fc8bb879350>: Failed to establish a new connection: [Errno 111] Connection refused',)': /simple/pip/
```

需要上传`setuptools-36.0.1.zip`与`pip-9.0.1.tar.gz`, 分别解压

cd setuptools-36.0.1
python2.7 setup.py install

cd pip-9.0.1/
python2.7 setup.py install

------

然后, 写hosts, 添加

192.168.160.5 pypi.python.org

修改/etc/pip.conf(没有的手动创建), 内容为

```
[global]
trusted-host = 192.168.160.200
index-url = http://192.168.160.200/pypi/simple
[search]
## 注意域名在hosts文件中重写, 端口, 以及访问路径
index = https://pypi.python.org:11443/pypi
```

然后安装saltstack

rm -f /etc/salt/pki/minion/minion_master.pub
pip2.7 install salt==2016.11.5


如果因为pyzmq装不上, 报如下错误

```
    bundled/zeromq/src/signaler.cpp: In static member function ‘static int zmq::signaler_t::make_fdpair(zmq::fd_t*, zmq::fd_t*)’:
    bundled/zeromq/src/signaler.cpp:322: error: ‘eventfd’ was not declared in this scope
    error: command 'gcc' failed with exit status 1
    
    ----------------------------------------
Command "/usr/local/python2.7/bin/python2.7 -u -c "import setuptools, tokenize;__file__='/tmp/pip-build-4M9sQ_/pyzmq/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /tmp/pip-WV9OqE-record/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /tmp/pip-build-4M9sQ_/pyzmq/
```

一般是在centos5.x系统上, 需要上传zeromq-4.1.6.tar.gz与pyzmq-16.0.2.tar.gz

分别解压

废弃步骤 ~~ yum install libsodium libsodium-devel -y ~~

废弃步骤 ~~./configure --prefix=/usr/local/zeromq --with-libsodium-lib-dir=/usr/lib --with-libsodium-include-dir=/usr/include/sodium ~~

```
cd zeromq-4.1.6
./configure --prefix=/usr/local/zeromq --without-libsodium
make && make install

cd pyzmq-16.0.2
python2.7 ./setup.py configure --zmq=/usr/local/zeromq
python2.7 ./setup.py install
```

好了, 再次安装salt即可. 

pip2.7 install salt==2016.11.5

参考

[手动安装pyzmq记录](http://blog.spider.im/2013/09/27/how-to-install-pyzmq/)

[ZeroMQ4.1.2关于libsodium问题](http://www.oschina.net/question/1438881_241712?sort=time)

------

## 配置文件

拷贝配置文件`minion`到`/etc/salt/minion`, 然后, centos 5, 6拷贝启动脚本`/salt-minion`到`/etc/init.d/`目录下.

```
\cp -f minion /etc/salt/minion
\cp -f salt-minion /etc/init.d/salt-minion
```

设置开机启动并启动

```
chkconfig salt-minion on
service salt-minion start
```

ok, 记得删除刚才上传的东西, 没用了.

```
rm -rf setuptools-36.0.1*
rm -rf Python-2.7.12*
rm -rf pip-9.0.1*
rm -f get-pip.py 
```

如果出现服务无法启动, 日志文件`/var/log/salt/minion`中有如下报错的情况.

```
2017-07-24 13:52:28,788 [salt.crypt][CRITICAL][373] The Salt Master has rejected this minion's public key!
To repair this issue, delete the public key for this minion on the Salt Master and restart this minion.
Or restart the Salt Master in open mode to clean out the keys. The Salt Minion will now exit.
2017-07-24 13:55:13,356 [salt.crypt][ERROR   ][475] The Salt Master has cached the public key for this node, this salt minion will wait for 10 seconds before attempting to re-authenticate
```

查看`/etc/salt/minion_id`, 其内容本应该是minion节点的hostname值, 如果不是, 手动修改后再次重启salt-minion服务即可.

------

## 验证

minion服务启动后登录`192.168.174.53`, 这是运维矩阵所在服务器. 

执行`salt-key -L`, 可以看到minion服务器的key列表, `Unaccepted Keys`中的是刚才minion的key, 红色字体(通过认证的是绿色的), 一般是minion服务器的`hostname`值.

使用`salt-key -A`接受minion的认证, 会提示输入`Y`的.

然后, 使用`salt '刚才minion的key值' test.ping`, 结果为True表示连接成功. 如下

```
[root@192-168-174-53 ~]# salt 'SANP_169_42.localdomain' test.ping
SANP_169_42.localdomain:
    True
```