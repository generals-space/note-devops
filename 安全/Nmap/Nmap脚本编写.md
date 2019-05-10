# Nmap脚本编写

<!tags!>: <!nmap脚本!> <!lua!>

原文链接

[writing nmap nse scripts for vulnerability scanning](http://thesprawl.org/research/writing-nse-scripts-for-vulnerability-scanning/)

[漏洞扫描 －－ 编写Nmap脚本](http://www.myhack58.com/Article/html/3/8/2014/54252.htm)

> 2006年12月份, `Nmap4.21 ALPHA1`版加入脚本引擎, 并将其作为主线代码的一部分.  `NSE`脚本库如今已经有400多个脚本, 覆盖了各种不同的网络机制(从SMB漏洞检测到Stuxnet探测, 及中间的一些内容). NSE 的强大, 依赖它强大的功能库, 这些库可以非常容易的与主流的网络服务和协议, 进行交互. 

## 挑战

我们经常会扫描网络环境中的主机是否存在某种新漏洞, 而扫描器引擎中没有新漏洞的检测方法, 这时候我们可能需要自己开发扫描工具. 

你可能已经熟悉了某种脚本(例如: `Python`, `Perl`, etc.) , 并可以快速写出检测漏洞的程序. 但是, 如果面临许多主机时,  针对两三个主机的检测方法, 可能并不奏效. 

Nmap解救你! 使用内嵌的`Lua`语言和强大的集合库, 你可以结合`nmap`高效的主机和端口扫描引擎, 开发出针对多数主机的检测方法.  

## 实现

Nmap引擎脚本, 由 **`Lua`编程语言**、**`NmapAPI`** 、**系列强大的`NSE`库** 实现. 

为了达到本文的目的, 现假设某个应用中存在一个叫`ArcticFission`漏洞. 与许多其他的 web应用程序类似, 可以通过探测特定的文件, 假设这个文件就是`/arcticfission.html`, 用正则表达式提取文件内容中的版本号, 与有漏洞的值进行对比. 听起来好像很简单, 让我们开始吧! 

## 框架代码 

基于传统的语言标准, 我们写一个脚本, 作用: 遇到开放的 HTTP 端口, 就返回`Hello World`. 

```lua
-- The Head Section --

-- The Rule Section --
-- 这种方式相当于匿名函数了
portrule = function(host, port)
    -- port.state为open的条件是必需的, 因为如果目标端口是一个filtered的状态, 没法执行这段代码
    -- 所以做实验的时候要确认目标主机的防火墙已关闭
    return port.protocol == "tcp" and port.number == 80 and port.state == "open"
end

-- The Action Section --
action = function(host, port)
    return "Hello world !"
end
```

> 注意: `lua`脚本中, 以`--`起始的行表示注释. 

NSE 脚本主要由三部分组成:

### 1. The Head Section

该部分包含一些元数据, 主要描述脚本的功能, 作者, 影响力, 类别及其他. 

### 2. The Rule Section

该部分定义脚本执行的必要条件. 至少包含下面列表中的一个函数:

- portrule

- hostrule

- prerule

- postrule

此案例中, 重点介绍`portrule`. `portrule`能够在执行操作前, 检查`host`和`port`属性. `portrule`会利用`nmap`的API检查TCP 80端口. 

### 3. The Action Section

该部分定义脚本逻辑. 此处案例中, 检测到开放 80 端口, 则打印`Hello World`. 脚本的输出内容, 会在`nmap`执行期间显示出来. 

> 注: 实际上nse脚本并不一定要如此分明的区分这三个部分, 也没有必要使用`-- xxx section --`进行分隔.

------

```
## 我们上面编写的脚本保存为http-vuln-check.nse文件, 最后一个参数为扫描对象, 可自定义
root@security:/home/offensive/nmap_nse# nmap -sS -p 22,80,443 --script /home/offensive/nmap_nse/http-vuln-check.nse www.exploit-db.com
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-29 10:39 EDT
Nmap scan report for www.exploit-db.com (192.99.12.218)
Host is up (0.47s latency).
Other addresses for www.exploit-db.com (not scanned): 198.58.102.135
rDNS record for 192.99.12.218: cloudproxy71.sucuri.net
PORT    STATE    SERVICE
22/tcp  filtered ssh
80/tcp  open     http
|_http-vuln-check: Hello world !
443/tcp open     https
```

> 注: 上面`80/tcp`的输出中, `http-vuln-check`字符串是所用脚本的名称.

## 调用脚本库

优秀的库集合, 促使其变的强大. 例如, 可调用现有库中的函数, 针对http端口创建`portrule`. 此处用到了 `shortport`(可在`/usr/share/nmap/nselib`目录中查看`shortport.lua`文件).

```lua
-- The Head Section --
local shortport = require "shortport"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    return "Hello world!"
end
```

同样的扫描, 产生了不同的结果

```
root@security:/home/offensive/nmap_nse# nmap -sS -p 22,80,443 --script /home/offensive/nmap_nse/http-vuln-check_shortport.nse www.exploit-db.com
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-29 10:36 EDT
Nmap scan report for www.exploit-db.com (192.99.12.218)
Host is up (0.46s latency).
Other addresses for www.exploit-db.com (not scanned): 198.58.102.135
rDNS record for 192.99.12.218: cloudproxy71.sucuri.net
PORT    STATE    SERVICE
22/tcp  filtered ssh
80/tcp  open     http
|_http-vuln-check_shortport: Hello world!
443/tcp open     https
|_http-vuln-check_shortport: Hello world!
Nmap done: 1 IP address (1 host up) scanned in 6.32 seconds
```

该脚本对443执行了类似80端口的操作. 主要是因为`shortport.http`表示类似HTTP的端口(80,443,631,7080,8080,8088,5800,3872,8180,8000), 也就是说, `nmap`会探测服务`http`、`https`、`ipp`、`http-alt`、`vnc-http`、`oem-agent`、`soap`、`http-proxy`非标准端口, 如果想要获取更多的信息, 请查阅 `shortport` 的文档.

## 服务探测

让我们把注意力放到 action 部分的逻辑上. 上述漏洞的检测, 首先需要探测页面`/arcticfission.html`

```lua
-- The Head Section --
local shortport = require "shortport"
local http = require "http"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    local uri = "/arcticfission.html"
    local response = http.get(host, port, uri)
    return response.status
end
```

上述代码用到了`http`库处理web页面

```
root@security:/home/offensive/nmap_nse# nmap -sS -p 22,80,443 --script /home/offensive/nmap_nse/http-vuln-check_shortport2.nse www.exploit-db.com
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-29 11:16 EDT
Nmap scan report for www.exploit-db.com (192.99.12.218)
Host is up (0.48s latency).
Other addresses for www.exploit-db.com (not scanned): 198.58.102.135
rDNS record for 192.99.12.218: cloudproxy71.sucuri.net
PORT    STATE    SERVICE
22/tcp  filtered ssh
80/tcp  open     http
|_http-vuln-check_shortport2: 403
443/tcp open     https
|_http-vuln-check_shortport2: 400
```

上述输出表明, 两个服务器端口不存在对应页面`arcticfission.html`, 注意`http`库会自动在http与https端口切换, 因此你不需要考虑去实现TLS/SSL. 

如果只想输出存在该页面的web应用, 可以如下操作:

```lua
-- The Head Section --
local shortport = require "shortport"
local http = require "http"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    local uri = "/arcticfission.html"
    local response = http.get(host, port, uri)
    if (response.status == 200) then
            return response.body
    end
end
```

上述代码, 返回状态码为200的页面的内容. 

> 注意: 如果没有数据返回或返回的页面为空, 将导致无输出显示.

## 漏洞探测

许多时候, 可以通过一个简单的服务版本号, 探测漏洞. 这种情况, 假象的服务器会返回一个包含版本号的标识. 

```lua
local shortport = require "shortport"
local http = require "http"
local string = require "string"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    local uri = "/arcticfission.html"
    local response = http.get(host, port, uri)
    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")
        return title
    end
end
```

上述代码, 用到了`string`库, 以便获取, 匹配页面头(这个`string`库是`lua`内置的). 

```
offensive@security:~/nmap_nse$ nmap -p 80,443 --script /home/offensive/nmap_nse/http-vuln-check_shortport4.nse 192.168.1.105
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-30 03:49 EDT
Nmap scan report for localhost (192.168.1.105)
Host is up (0.00053s latency).
PORT    STATE  SERVICE
80/tcp  open   http
|_http-vuln-check_shortport4: 1.0
443/tcp closed https
Nmap done: 1 IP address (1 host up) scanned in 0.07 seconds
```

正如上面描述的那样, 现在需要将获取的值与漏洞值比较,  确认是否存在漏洞. 

```lua
-- The Rule Section --
local shortport = require "shortport"
local http = require "http"
local string = require "string"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    local uri = "/arcticfission.html"
    local response = http.get(host, port, uri)
    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission ([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")
        if ( title == "1.0" ) then
            return "Vnlnerable"
        else
            return "Not Vulnerable"
        end
    end
end
```

测试结果如下(这里与前面的被测主机不一样, 并且443端口是closed状态, 所以不会有`Not Vulnerable`输出):

```
offensive@security:~/nmap_nse$ nmap -p 80,443 --script /home/offensive/nmap_nse/http-vuln-check_shortport5.nse 192.168.1.105
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-30 04:05 EDT
Nmap scan report for localhost (192.168.1.105)
Host is up (0.00045s latency).
PORT    STATE  SERVICE
80/tcp  open   http
|_http-vuln-check_shortport5: Vnlnerable
443/tcp closed https
```

版本检测的另一种方法, 生成Hash与有漏洞的页面对比. 为了实现此效果, 此处调用了`openssl`库. 

```lua
-- The Head Section --
local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local openssl = require "openssl"
-- The Rule Section --
portrule = shortport.http
-- The Action Section --
action = function(host, port)
    local uri = "/arcticfission.html"
    local response = http.get(host, port, uri)
    if (response.status == 200) then
        local vulnsha1 = "398ffad678f17a4f16ccd00b1914ca986d0b9258"
        -- 比较页面内容的哈希值???
        local sha1 = string.lower(stdnse.tohex(openssl.sha1(response.body)))
        if ( sha1 == vulnsha1 ) then
            return "Vulnerable"
        else
            return "Not Vulnerable"
        end
    end
end
```

## 添加隐藏属性

使用第三方的库时，测试脚本的执行流程很重要(`--script-trace`选项的应用, 貌似只有指定端口的扫描时才会有效...)。

```
offensive@security:~/nmap_nse$ nmap -p 80,443 --script /home/offensive/nmap_nse/http-vuln-check_openssl.nse --script-trace 192.168.1.105
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-30 05:38 EDT
NSOCK INFO [0.0600s] nsi_new2(): nsi_new (IOD #1)
NSOCK INFO [0.0610s] nsock_connect_tcp(): TCP connection requested to 192.168.1.105:80 (IOD #1) EID 8
NSOCK INFO [0.0610s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 8 [192.168.1.105:80]
NSE: TCP 192.168.1.106:59791 > 192.168.1.105:80 | CONNECT
NSE: TCP 192.168.1.106:59791 > 192.168.1.105:80 | 00000000: 47 45 54 20 2f 61 72 63 74 69 63 66 69 73 73 69 GET /arcticfissi
00000010: 6f 6e 2e 68 74 6d 6c 20 48 54 54 50 2f 31 2e 31 on.html HTTP/1.1
00000020: 0d 0a 48 6f 73 74 3a 20 6c 6f 63 61 6c 68 6f 73   Host: localhos
00000030: 74 0d 0a 43 6f 6e 6e 65 63 74 69 6f 6e 3a 20 63 t  Connection: c
00000040: 6c 6f 73 65 0d 0a 55 73 65 72 2d 41 67 65 6e 74 lose  User-Agent
00000050: 3a 20 4d 6f 7a 69 6c 6c 61 2f 35 2e 30 20 28 63 : Mozilla/5.0 (c
00000060: 6f 6d 70 61 74 69 62 6c 65 3b 20 4e 6d 61 70 20 ompatible; Nmap  
00000070: 53 63 72 69 70 74 69 6e 67 20 45 6e 67 69 6e 65 Scripting Engine
00000080: 3b 20 68 74 74 70 3a 2f 2f 6e 6d 61 70 2e 6f 72 ; http://nmap.or
00000090: 67 2f 62 6f 6f 6b 2f 6e 73 65 2e 68 74 6d 6c 29 g/book/nse.html)
000000a0: 0d 0a 0d 0a                                          
NSOCK INFO [0.0620s] nsock_trace_handler_callback(): Callback: WRITE SUCCESS for EID 19 [192.168.1.105:80]
NSE: TCP 192.168.1.106:59791 > 192.168.1.105:80 | SEND
NSOCK INFO [0.0620s] nsock_read(): Read request from IOD #1 [192.168.1.105:80] (timeout: 8000ms) EID 26
NSOCK INFO [0.0640s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 26 [192.168.1.105:80] (392 bytes)
NSE: TCP 192.168.1.106:59791 < 192.168.1.105:80 | 00000000: 48 54 54 50 2f 31 2e 31 20 32 30 30 20 4f 4b 0d HTTP/1.1 200 OK  
00000010: 0a 44 61 74 65 3a 20 54 75 65 2c 20 33 30 20 53  Date: Tue, 30 S
00000020: 65 70 20 32 30 31 34 20 30 39 3a 33 38 3a 34 39 ep 2014 09:38:49
00000030: 20 47 4d 54 0d 0a 53 65 72 76 65 72 3a 20 41 70  GMT  Server: Ap
00000040: 61 63 68 65 2f 32 2e 32 2e 32 32 20 28 44 65 62 ache/2.2.22 (Deb
00000050: 69 61 6e 29 0d 0a 4c 61 73 74 2d 4d 6f 64 69 66 ian)  Last-Modif
00000060: 69 65 64 3a 20 54 75 65 2c 20 33 30 20 53 65 70 ied: Tue, 30 Sep
00000070: 20 32 30 31 34 20 30 37 3a 33 30 3a 33 33 20 47  2014 07:30:33 G
00000080: 4d 54 0d 0a 45 54 61 67 3a 20 22 65 31 31 38 31 MT  ETag: "e1181
00000090: 2d 37 34 2d 35 30 34 34 33 35 62 64 38 36 62 30 -74-504435bd86b0
000000a0: 32 22 0d 0a 41 63 63 65 70 74 2d 52 61 6e 67 65 2"  Accept-Range
000000b0: 73 3a 20 62 79 74 65 73 0d 0a 43 6f 6e 74 65 6e s: bytes  Conten
000000c0: 74 2d 4c 65 6e 67 74 68 3a 20 31 31 36 0d 0a 56 t-Length: 116  V
000000d0: 61 72 79 3a 20 41 63 63 65 70 74 2d 45 6e 63 6f ary: Accept-Enco
000000e0: 64 69 6e 67 0d 0a 43 6f 6e 6e 65 63 74 69 6f 6e ding  Connection
000000f0: 3a 20 63 6c 6f 73 65 0d 0a 43 6f 6e 74 65 6e 74 : close  Content
00000100: 2d 54 79 70 65 3a 20 74 65 78 74 2f 68 74 6d 6c -Type: text/html
00000110: 0d 0a 0d 0a 3c 68 74 6d 6c 3e 0a 3c 68 65 61 64     <html> <head
00000120: 3e 0a 3c 74 69 74 6c 65 3e 41 72 63 74 69 63 46 > <title>ArcticF
00000130: 69 73 73 69 6f 6e 20 31 2e 30 3c 2f 74 69 74 6c ission 1.0</titl
00000140: 65 3e 0a 3c 2f 68 65 61 64 3e 0a 3c 62 6f 64 79 e> </head> <body
00000150: 3e 0a 3c 68 31 3e 57 65 6c 63 6f 6d 65 20 74 6f > <h1>Welcome to
00000160: 20 41 72 63 74 69 63 46 69 73 73 69 6f 6e 20 31  ArcticFission 1
00000170: 2e 30 3c 2f 68 31 3e 0a 3c 2f 62 6f 64 79 3e 0a .0</h1> </body>  
00000180: 3c 2f 68 74 6d 6c 3e 0a                         </html>  
NSE: TCP 192.168.1.106:59791 > 192.168.1.105:80 | CLOSE
NSOCK INFO [0.0640s] nsi_delete(): nsi_delete (IOD #1)
Nmap scan report for localhost (192.168.1.105)
Host is up (0.00064s latency).
PORT    STATE  SERVICE
80/tcp  open   http
|_http-vuln-check_openssl: Vulnerable
443/tcp closed https
Nmap done: 1 IP address (1 host up) scanned in 0.07 seconds
```

从上面的跟踪看， NSE 的 `http` 库使用的默认 `User-Agent` 是“Mozilla/5.0(compatible; Nmap Scripting Engine;http://nmap.org/book/nse.html)”. 可能由于某些安全原因，你需要更改 `user-agent`，可使用下面方法.

```
offensive@security:~/nmap_nse$ nmap -p 80,443 --script /home/offensive/nmap_nse/http-vuln-check_openssl.nse --script-args="http.useragent='Mozilla/5.0 (compatible [offensive@security])'" --script-trace 192.168.1.105
Starting Nmap 6.47 ( http://nmap.org ) at 2014-09-30 06:08 EDT
NSOCK INFO [0.2590s] nsi_new2(): nsi_new (IOD #1)
NSOCK INFO [0.2600s] nsock_connect_tcp(): TCP connection requested to 192.168.1.105:80 (IOD #1) EID 8
NSOCK INFO [0.2610s] nsock_trace_handler_callback(): Callback: CONNECT SUCCESS for EID 8 [192.168.1.105:80]
NSE: TCP 192.168.1.106:59923 > 192.168.1.105:80 | CONNECT
NSE: TCP 192.168.1.106:59923 > 192.168.1.105:80 | 00000000: 47 45 54 20 2f 61 72 63 74 69 63 66 69 73 73 69 GET /arcticfissi
00000010: 6f 6e 2e 68 74 6d 6c 20 48 54 54 50 2f 31 2e 31 on.html HTTP/1.1
00000020: 0d 0a 48 6f 73 74 3a 20 31 39 32 2e 31 36 38 2e   Host: 192.168.
00000030: 31 2e 31 30 35 0d 0a 55 73 65 72 2d 41 67 65 6e 1.105  User-Agen
00000040: 74 3a 20 4d 6f 7a 69 6c 6c 61 2f 35 2e 30 20 28 t: Mozilla/5.0 (
00000050: 63 6f 6d 70 61 74 69 62 6c 65 20 5b 6f 66 66 65 compatible [offe
00000060: 6e 73 69 76 65 40 73 65 63 75 72 69 74 79 5d 29 nsive@security])
00000070: 0d 0a 43 6f 6e 6e 65 63 74 69 6f 6e 3a 20 63 6c   Connection: cl
00000080: 6f 73 65 0d 0a 0d 0a                            ose     
NSOCK INFO [0.2610s] nsock_trace_handler_callback(): Callback: WRITE SUCCESS for EID 19 [192.168.1.105:80]
NSE: TCP 192.168.1.106:59923 > 192.168.1.105:80 | SEND
NSOCK INFO [0.2610s] nsock_read(): Read request from IOD #1 [192.168.1.105:80] (timeout: 8000ms) EID 26
NSOCK INFO [0.2640s] nsock_trace_handler_callback(): Callback: READ SUCCESS for EID 26 [192.168.1.105:80] (392 bytes)
NSE: TCP 192.168.1.106:59923 < 192.168.1.105:80 | 00000000: 48 54 54 50 2f 31 2e 31 20 32 30 30 20 4f 4b 0d HTTP/1.1 200 OK  
00000010: 0a 44 61 74 65 3a 20 54 75 65 2c 20 33 30 20 53  Date: Tue, 30 S
00000020: 65 70 20 32 30 31 34 20 31 30 3a 30 38 3a 32 34 ep 2014 10:08:24
00000030: 20 47 4d 54 0d 0a 53 65 72 76 65 72 3a 20 41 70  GMT  Server: Ap
00000040: 61 63 68 65 2f 32 2e 32 2e 32 32 20 28 44 65 62 ache/2.2.22 (Deb
00000050: 69 61 6e 29 0d 0a 4c 61 73 74 2d 4d 6f 64 69 66 ian)  Last-Modif
00000060: 69 65 64 3a 20 54 75 65 2c 20 33 30 20 53 65 70 ied: Tue, 30 Sep
00000070: 20 32 30 31 34 20 30 37 3a 33 30 3a 33 33 20 47  2014 07:30:33 G
00000080: 4d 54 0d 0a 45 54 61 67 3a 20 22 65 31 31 38 31 MT  ETag: "e1181
00000090: 2d 37 34 2d 35 30 34 34 33 35 62 64 38 36 62 30 -74-504435bd86b0
000000a0: 32 22 0d 0a 41 63 63 65 70 74 2d 52 61 6e 67 65 2"  Accept-Range
000000b0: 73 3a 20 62 79 74 65 73 0d 0a 43 6f 6e 74 65 6e s: bytes  Conten
000000c0: 74 2d 4c 65 6e 67 74 68 3a 20 31 31 36 0d 0a 56 t-Length: 116  V
000000d0: 61 72 79 3a 20 41 63 63 65 70 74 2d 45 6e 63 6f ary: Accept-Enco
000000e0: 64 69 6e 67 0d 0a 43 6f 6e 6e 65 63 74 69 6f 6e ding  Connection
000000f0: 3a 20 63 6c 6f 73 65 0d 0a 43 6f 6e 74 65 6e 74 : close  Content
00000100: 2d 54 79 70 65 3a 20 74 65 78 74 2f 68 74 6d 6c -Type: text/html
00000110: 0d 0a 0d 0a 3c 68 74 6d 6c 3e 0a 3c 68 65 61 64     <html> <head
00000120: 3e 0a 3c 74 69 74 6c 65 3e 41 72 63 74 69 63 46 > <title>ArcticF
00000130: 69 73 73 69 6f 6e 20 31 2e 30 3c 2f 74 69 74 6c ission 1.0</titl
00000140: 65 3e 0a 3c 2f 68 65 61 64 3e 0a 3c 62 6f 64 79 e> </head> <body
00000150: 3e 0a 3c 68 31 3e 57 65 6c 63 6f 6d 65 20 74 6f > <h1>Welcome to
00000160: 20 41 72 63 74 69 63 46 69 73 73 69 6f 6e 20 31  ArcticFission 1
00000170: 2e 30 3c 2f 68 31 3e 0a 3c 2f 62 6f 64 79 3e 0a .0</h1> </body>  
00000180: 3c 2f 68 74 6d 6c 3e 0a                         </html>  
NSE: TCP 192.168.1.106:59923 > 192.168.1.105:80 | CLOSE
NSOCK INFO [0.2660s] nsi_delete(): nsi_delete (IOD #1)
Nmap scan report for 192.168.1.105
Host is up (0.00053s latency).
PORT    STATE  SERVICE
80/tcp  open   http
|_http-vuln-check_openssl: Vulnerable
443/tcp closed https
Nmap done: 1 IP address (1 host up) scanned in 0.27 seconds
```

当然, 你也可以在脚本中调用`http`库时在请求头中直接指定`User-Agent`的值. 如下

```lua
local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"

-- The Rule Section --
portrule = shortport.http

-- The Action Section --
action = function(host, port)

    local uri = "/arcticfission.html"

    local options = {header={}}
    options['header']['User-Agent'] = "Mozilla/5.0 (compatible; ArcticFission)"

    local response = http.get(host, port, uri, options)

    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission ([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")

        if ( title == "1.0" ) then
            return "Vulnerable"
        else        
            return "Not Vulnerable"
        end
    end
end
```

## 包装脚本

如果你想要发布脚本，有些重要的元数据需要提供，例如：描述、作者信息、证书，以便理解脚本的功能与影响力.

```lua
-- The Head Section --
description = [[Sample script to detect a fictional vulnerability
in a fictional ArcticFission 1.0 web server]]
author = "iphelix"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"default", "safe"}

local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"

-- The Rule Section --
portrule = shortport.http

-- The Action Section --
action = function(host, port)

    local uri = "/arcticfission.html"

    local options = {header={}}
    options['header']['User-Agent'] = "Mozilla/5.0 (compatible; ArcticFission)"

    local response = http.get(host, port, uri, options)

    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission ([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")

        if ( title == "1.0" ) then
            return "Vulnerable"
        else        
            return "Not Vulnerable"
        end
    end
end
```

你现在可能想写入一些 NSE 文档格式的说明。脚本文档可能包含一些可能会被文档系统处理的特殊标识。 ( 例如 `@output` 表示脚本输出， `@args` 表示脚本参数，`@usage` 表示简单的命令行参数，等 )

```lua
-- The Head Section --
description = [[Sample script to detect a fictional vulnerability
in a fictional ArcticFission 1.0 web server]]

---
-- @usage
-- nmap --script http-vuln-check <target>
-- @output
-- PORT   STATE SERVICE
-- 80/tcp open  http
-- |_http-vuln-check: Vulnerable

author = "iphelix"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"default", "safe"}

local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"

-- The Rule Section --
portrule = shortport.http

-- The Action Section --
action = function(host, port)

    local uri = "/arcticfission.html"

    local options = {header={}}
    options['header']['User-Agent'] = "Mozilla/5.0 (compatible; ArcticFission)"

    local response = http.get(host, port, uri, options)

    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission ([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")

        if ( title == "1.0" ) then
            return "Vulnerable"
        else        
            return "Not Vulnerable"
        end
    end
end
```

## 解析输出

使用自定义的脚本检测完成后，我们还需要解析产生的结果，以易理解的方式输出报告。不幸的是， 'gnmap' 输出格式不支持脚本输出，所以我们选择解析 'xml' 格式的输出。

```py
#!/usr/bin/env python
# nmap-xml-parse by iphelix
import sys
from xml.dom.minidom import parse

if len(sys.argv) != 2:
    print "Usage: %s nmap_output.xml"
    sys.exit(1)

nmap = parse(sys.argv[1])

for host in nmap.getElementsByTagName("host"):
    addresses = [addr.getAttribute("addr") for addr in host.getElementsByTagName("address")]

    for port in host.getElementsByTagName("port"):
        portid = port.getAttribute("portid")

        for script in port.getElementsByTagName("script"):
            if script.getAttribute("id") == "http-vuln-check":
                output = script.getAttribute("output")

                for address in addresses:
                    print "%s,%s,%s" % (address, portid, output)
```

上述脚本的使用方法

```
# nmap --script http-vuln-check localhost -p 80,443 -oA http-vuln

Starting Nmap 6.25 ( http://nmap.org ) at 2013-01-11 02:47 EST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000066s latency).
Other addresses for localhost (not scanned): 127.0.0.1
PORT    STATE SERVICE
80/tcp  open  http
|_http-vuln-check: Vulnerable
443/tcp open  https
|_http-vuln-check: Vulnerable

Nmap done: 1 IP address (1 host up) scanned in 8.08 seconds
# ./nmap-xml-parse.py http-vuln.xml
127.0.0.1,80,Vulnerable
127.0.0.1,443,Vulnerable
```

这样的输出很容易被转换成csv格式的文件, 按照不同的需求, 修改起来也很方便.

## 漏洞管理

上述漏洞发现脚本有些问题。首先，它没有漏洞相关的描述信息，其次，完成扫描后，你需要编写脚本解析整个扫描结果。上面的这些，可以用 Nmap 的库 'vulns' 进行处理。

### NSE 漏洞库

NSE 漏洞库 由 DjalalHarouni 和 HenriDoreau 开发，目的是标准化呈现与管理漏洞。

```lua
-- The Head Section --
description = [[Sample script to detect a fictional vulnerability
in a fictional ArcticFission 1.0 web server]]

---
-- @usage
-- nmap --script http-vuln-check <target>
-- @output
-- PORT    STATE SERVICE
-- 80/tcp  open  http
-- | http-vuln-check: 
-- |   VULNERABLE:
-- |   ArcticFission 1.0 Vulnerability
-- |     State: VULNERABLE
-- |     IDs:  CVE:CVE-XXXX-XX
-- |     References:
-- |_      http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-XXXX-XX


author = "iphelix"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"default", "safe"}

local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local vulns = require "vulns"

-- The Rule Section --
portrule = shortport.http

-- The Action Section --
action = function(host, port)

    -- The Vuln Definition Section --
    local vuln = {
        title = "ArcticFission 1.0 Vulnerability",
        state = vulns.STATE.NOT_VULN, --default
        IDS = { CVE = 'CVE-XXXX-XX' }
    }   
    local report = vulns.Report:new(SCRIPT_NAME, host, port)

    local uri = "/arcticfission.html"

    local options = {header={}}
    options['header']['User-Agent'] = "Mozilla/5.0 (compatible; ArcticFission)"

    local response = http.get(host, port, uri, options)

    if ( response.status == 200 ) then
        local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>ArcticFission ([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")

        if ( title == "1.0" ) then
            vuln.state = vulns.STATE.VULN
        else        
            vuln.state = vulns.STATE.NOT_VULN
        end
    end

    return report:make_output(vuln)
end
```

扫描结果如下:

```
# nmap --script http-vuln-check localhost -p 80,443

Starting Nmap 6.25 ( http://nmap.org ) at 2013-01-11 02:52 EST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000038s latency).
Other addresses for localhost (not scanned): 127.0.0.1
PORT    STATE SERVICE
80/tcp  open  http
| http-vuln-check: 
|   VULNERABLE:
|   ArcticFission 1.0 Vulnerability
|     State: VULNERABLE
|     IDs:  CVE:CVE-XXXX-XX
|     References:
|_      http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-XXXX-XX
443/tcp open  https
| http-vuln-check: 
|   VULNERABLE:
|   ArcticFission 1.0 Vulnerability
|     State: VULNERABLE
|     IDs:  CVE:CVE-XXXX-XX
|     References:
|_      http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-XXXX-XX
```