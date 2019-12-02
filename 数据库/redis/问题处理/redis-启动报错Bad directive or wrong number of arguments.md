# redis-启动报错Bad directive or wrong number of arguments

## 问题描述

redis安装完成, 但启动报错, redis版本: 3.0.7

```
redis-server /usr/local/etc/redis.conf
*** FATAL CONFIG FILE ERROR ***
Reading the configuration file, at line 54
>>> 'tcp-backlog 511'
Bad directive or wrong number of arguments```
```

## 原因分析

redis的配置文件与安装的redis程序不是同一个版本, 有可能是之前安装过redis, 此次启动读取的是之前的配置文件. 顺便可以查看时不是已经有一个redis进程在运行了.

## 解决办法

记得停止正在运行的redis进程, 删除可执行文件, 配置文件等内容, 然后再次尝试启动新的redis.
