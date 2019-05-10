# Nmap脚本入门

参考文章

1. [Nmap内置库](https://nmap.org/nsedoc/lib/)

nmap内置了lua脚本引擎, 其脚本都是用lua写的. 但是, 就像安卓程序是用java编写一样, 虽然需要遵循lua语法, 更重要的还是, 遵守nmap的框架规则.

nmap是扫描工具, 目标是服务器, 地址索引是ip, 端口. 所以脚本代码一般需要一个触发条件.

而且, 我个人一直相信, 新语言入门最好的示例是一个'hello world'. 然后, 在编写实际应用代码最先要掌握的就是变量定义, 信息输出, 注释, 然后是变量, 函数的定义等等...

在nmap脚本中, 主要有两个部分(其实貌似有三个部分, 不过我觉得剩下的没必要单独写).

### 1. The Rule Section

该部分定义脚本执行的必要条件. 至少包含下面列表中的一个函数:

- portrule

- hostrule

- prerule

- postrule

### 2. The Action Section

该部分定义脚本逻辑. 此处案例中, 检测到开放 80 端口, 则打印`Hello World`. 脚本的输出内容, 会在`nmap`执行期间显示出来. 

------

下面是一个最简单nmap脚本的示例.

```lua
local shortport = require 'shortport'
local stdnse = require 'stdnse'
portrule = shortport.http

-- 有点像匿名函数
action = function(host, port)
    stdnse.debug('hello world')
    stdnse.verbose('hello world')
end
```

`require`是lua中包引用方式, 语法类似于`nodejs`.

`stdnse`是nmap自带的lib库, 有一些在nmap脚本中常用的工具函数可以使用.

`stdnse.debug(msg)` 只在`nmap -d`中可输出.

`stdnse.verbose(msg)`: 在`-d`或是`--script-strace`中都可输出.

上述脚本执行方法如下

```
$ nmap --script=/usr/share/nmap/myscripts/myscript.nse -p 80 -d www.baidu.com
```

![](http://img.generals.spcace/21ca273ca77a3ce1394f48e67e881adc.png)

------

再仔细分析一个上述代码的结构. 

上述代码中, `portrule`能够在执行操作前, 检查`host`和`port`属性. `portrule`会利用`nmap`的API检查目标主机80, 443端口. action会向其指定函数中传递两个参数`host`和`port`. 这两个参数都是`table`类型(也就是关联数组, 可以使用lua内置的`type(var)`查看).

好吧, 下面打印出action函数中host中的键值对瞧瞧.

```lua
local shortport = require 'shortport'
local stdnse = require 'stdnse'
portrule = shortport.http

action = function(host, port)
    stdnse.debug('hello world')
    stdnse.verbose('hello world')
    stdnse.verbose(type(host))
    stdnse.verbose(type(port))
    for k, v in pairs(host) do
        stdnse.verbose('key: %s, type: %s, value: %s', k, type(k), v)
    end 
end
```

debug模式下再次扫描百度网站, 有如下输出.

```
NSE: [myscript 115.239.211.112:80] key: registry, type: string, value: table: 0x55cfb33780b0
NSE: [myscript 115.239.211.112:80] key: directly_connected, type: string, value: false
NSE: [myscript 115.239.211.112:80] key: name, type: string, value: 
NSE: [myscript 115.239.211.112:80] key: reason_ttl, type: string, value: 128
NSE: [myscript 115.239.211.112:80] key: ip, type: string, value: 115.239.211.112
NSE: [myscript 115.239.211.112:80] key: targetname, type: string, value: www.baidu.com
NSE: [myscript 115.239.211.112:80] key: bin_ip_src, type: string, value: ¬ d(
NSE: [myscript 115.239.211.112:80] key: mac_addr_src, type: string, value: 
NSE: [myscript 115.239.211.112:80] key: reason, type: string, value: reset
NSE: [myscript 115.239.211.112:80] key: interface, type: string, value: eth0
NSE: [myscript 115.239.211.112:80] key: interface_mtu, type: string, value: 1500
NSE: [myscript 115.239.211.112:80] key: bin_ip, type: string, value: s𐒰
NSE: [myscript 115.239.211.112:80] key: times, type: string, value: table: 0x55cfb3c8a9c0
```

> 呃...stdnse标准库里有一个`format_output (status, data, indent)`函数专门用来格式化输出table类型变量的, 不过在这里不太管用. 应该是host, port不是标准的table类型??? [官网示例](https://nmap.org/nsedoc/lib/stdnse.html#output_table)中的table倒是挺标准的.

**补充**

通过如下方式定义的变量, 虽然用`type`函数查看的也是table类型, 但的确没法用`stdnse.format_output()`函数输出.

```lua
    local objs = { 
        person = { 
            name = 'general',
            age = 23, 
            skill = { 
                'c', 'c++', 'js', 'python'
            }   
        }   
    }   
```