# Nmap脚本入门-stdnse库

参考文章

1. [Library stdnse](https://nmap.org/nsedoc/lib/stdnse.html)

nse脚本中, 很多函数都不能使用内置的, 都放大`stdnse`库中了, 比如获取命令行参数, 打印消息等方法.

`SCRIPT_NAME`: nmap引擎内置变量, 表示当前运行脚本的名称(不带nse后缀)

`stdnse.get_script_args(参数名)`: 从命令行获取参数, 可以直接使用`stdnse.verbose()`输出查看.

示例

```lua
-- filename: /usr/share/nmap/myscripts/myscript.nse
local shortport = require 'shortport'
local stdnse = require 'stdnse'
portrule = shortport.http

action = function(host, port)
    stdnse.verbose('hello world')
    local name = stdnse.get_script_args('name')
    local age = stdnse.get_script_args('age')
    -- 字符串拼接方法: ..
    stdnse.verbose(name .. ': ' .. age)
end
```

使用方法如下

```
$ nmap --script /usr/share/nmap/myscripts/myscript.nse -d -p 80 --script-args name=general,age=23 www.baidu.com
```

将得到如下输出 

```
...
NSE: [myscript 115.239.210.27:80] hello world
NSE: [myscript 115.239.210.27:80] general: 23
...
```

`generate_random_string (len, charset)`: 生成随机字符串, `len`表示字符串长度, `charset`表示字符串的父集, 默认从`a-Z`, 可以是str类型, 也可以是table类型, 不过具体还不知道怎么用. 