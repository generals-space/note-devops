# Apache-日志分割

参考文章

1. [apache中log的logrotate设置](http://blog.csdn.net/hantiannan/article/details/5447512)

2. [apache日志管理](http://blog.chinaunix.net/uid-25266990-id-95790.html)

一般是按天分割(想按月的太天真了). 可以通过apache自带的`rotatelogs`命令实现, 不管是yum安装还是源码安装都是有这个命令的. 前者可以通过`whereis`命令找到, 一般在`/usr/sbin/rotatelogs`, 后者就在`$APACHE_HOME/bin/rotatelogs`.

编辑`httpd.conf`, yum安装时在`/etc/httpd/conf/httpd.conf`, 源码安装时在`$APACHE_HOME/conf/httpd.conf`. 将`CustomLog`与`ErrorLog`字段分别改成如下.

```
## 普通日志
CustomLog "|/usr/local/apache/bin/rotatelogs /usr/local/apache/logs/access_%Y-%m-%d.log 86400 540" combined
## 错误日志
ErrorLog "|/usr/local/apache/bin/rotatelogs /usr/local/apache/logs/error_%Y%m%d.log 86400 540"
```

注意:

1. `rotatelogs`命令路径, 要与实际情况相符

2. 日志位置自定义, 86400 = 60 * 60 * 24, 按天分割日志, 540指日志超过540M时强制分割日志.

3. combined是日志格式名, 通过LogFormat字段定义不同格式. 不同的名称, 日志的详细程度不同. ErrorLog如果没有这个日志名称(或者不在其"作用域")不能添加.

```
## graceful子指令可以平滑重启httpd服务
apachectl -k graceful
```
