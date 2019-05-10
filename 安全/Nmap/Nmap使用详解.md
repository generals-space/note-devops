# Nmap使用详解

1. [使用nmap 验证多种漏洞](http://blog.csdn.net/qq_29277155/article/details/50977143)

nmap的man手册有近2000行, 而且章节分部不明晰, 很难阅读.

nmap貌似默认只扫描1000以内的端口

## 1. 选项

### 1.1 选项

`-p` 扫描的目标端口, 可以指定单个端口号, 也可以指定端口范围.

### 1.2 扫描方式

`-sS` (TCP SYN scan)

隐身扫描, 默认扫描方式.

`-sT` (TCP connect scan)

`-sU` (UDP scan)

> 可以看出, 第一个小写的`s`表示`scan`(扫描), 后面紧跟的`S`, `T`, `U`等, 为扫描方式. 

`-sP` (No port scan)

又叫`-sn`, 只完成主机发现任务, 不进行端口扫描. 最适合用来检测目标主机存活状态.

`-sV` (Version detection)

也叫`-sR`, 对目标主机的开放端口进入服务和版本扫描.

------

`-Pn` (No ping)

也叫`-P0`/`-PN`

有些防火墙禁ping, 会让nmap认为目标主机未启动. 这个选项可以让nmap直接跳过主机发现这个阶段, 直接进入到端口检测部分. 十分有用.

### 1.3 功能选项

`-A` 这是一个集合选项, 相当于`-O` + `-sV` + `-sC` + `--traceroute`

`-O` 尝试识别远程操作系统, 单独使用时其实也伴随着某些端口的扫描.


### 1.4 端口状态

在nmap的man手册中, **PORT SCANNING BASICS**节有目标端口的状态与解释.

1. open（开放的）

2. closed（关闭的）

3. filtered（被过滤的）不确定开放还是关闭

4. unfiltered （未被过滤的）

5. openfiltered （开放或者被过滤的）

6. closedfiltered （关闭或者未被过滤的）

### 结果输出

`-oN 文件名` (normal output)

普通输出

`-oX 文件名` (XML output)

### 扫描实例

扫描指定端口范围的服务. 

```
$ nmap -sV -p 1024-65535 98.142.137.70
```

## 脚本

> Kali默认的nse脚本位置在`/usr/share/nmap/scripts`.

`redis-info`脚本使用方法示例

```
root@kali:~# nmap -p 6379 98.142.137.70 --script redis-info

Starting Nmap 7.40 ( https://nmap.org ) at 2017-04-24 03:03 CST
Nmap scan report for 98.142.137.70.16clouds.com (98.142.137.70)
Host is up (0.038s latency).
PORT     STATE SERVICE
6379/tcp open  redis
| redis-info: 
|   Version            2.4.10
|   Architecture       32 bits
|   Process ID         586
|   Used CPU (sys)     1.81
|   Used CPU (user)    0.82
|   Connected clients  1
|   Connected slaves   0
|   Used memory        542.94K
|_  Role               master
```

如果脚本在自定义的路径下, 也可以写全路径.