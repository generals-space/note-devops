# nc交互式服务器[socket web http server]

参考文章

1. [Minimal web server using netcat](https://stackoverflow.com/questions/16640054/minimal-web-server-using-netcat)
2. [avleen/bashttpd](https://github.com/avleen/bashttpd)

## 场景描述

nc的常规用法是启动一个 socket server, 客户端连接后可以持续相互发送消息, 直到某一方断开.

server

```log
$ nc -l 8080
hello world
hello kitty
hello kugou
```

client

```log
$ nc 127.0.0.1 8080
hello world
hello kitty
hello kugou
^C
```

在 k8s 集群中, 某个 Pod 的健康检查脚本是使用 nc 发送"ruok"到指定端口, 如果得到"imok"的返回, 就认为当前服务正常(kubelet每隔一段时间就会执行一遍检查脚本).

脚本内容为

```bash
#! /bin/bash
var=$(echo ruok|nc 127.0.0.1 8888)
if [[ $var == "imok" ]]; then
    exit 0
else
    exit 1
fi
```

现在想用 nc 命令模拟一个服务出来, 让健康检查脚本可以通过.

## 1. while 循环

最初的需求里, 我们并不关心客户端发送了什么, 是不是"ruok", 只要能持续返回"imok"就行.

参考文章1中提到了2种方案

### 1.1

```bash
while true; do
    echo -e "imok" | nc -l 8888; 
done
```

client 测试

```log
$ echo ruok|nc 127.0.0.1 8888
imok
```

### 1.2 舍弃

下面这种是行不通的, ta只适合交互式的客户端, 如果是`echo ruok|nc 127.0.0.1 8888`这种行内命令, 则无法获取到输出.

```bash
while true; do
    nc -l 8888 -c 'echo -e "ruok"';
done
```

client 测试

```log
$ nc 127.0.0.1 8888
ruok ## 这里倒是能得到需要的输出
ls   ## 但是再输入其他的也是没有响应的
^C
```

## 2. 进阶, 根据客户端消息返回不同结果.

下面是探索阶段

如果希望 server 根据客户端消息返回不同的结果, 首先 server 端要能得到客户端发来的信息.

```bash
mkfifo pipe;
while true; do 
    { 
        read body < pipe
        echo hello $body
    } | nc -l -p 8888 > pipe;
done
```

但这种只能在交互模式下生效, 且只有一次对话的机会.

```log
$ nc 127.0.0.1 8888
world
hello world
kugou ## 这里开始就没有响应了, server 端会出现"write: Broken pipe"错误(但不影响新的 client 连接).
```

```log
$ echo kugou | nc 127.0.0.1 8888
## 没有任何输出
```

对应这种情况, 参考文章1中倒没有解释, 而且这种一次性的连接正好适合 http 请求, 所以他们讨论的大都是用 nc 实现 web server 的方案.

## 3. web server

简单的 web server 也只是一个 while 循环, 只不过响应体格式需要遵守 http 协议.

```bash
while true; do 
    echo -e "HTTP/1.1 200 OK\n\n $(date)" | nc -l 8888
done
```

使用 curl 测试

```log
$ curl localhost:8888
 2024年 05月 30日 星期四 16:57:13 CST
```

更复杂的就可以使用 bashhttpd 服务了, 见参考文章2.

```
netcat -lp 8080 -e ./bashttpd
```
