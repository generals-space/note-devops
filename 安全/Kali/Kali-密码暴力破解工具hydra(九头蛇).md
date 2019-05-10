# Kali-密码暴力破解工具hydra

参考文章

1. [kali下使用Hydra暴力破解DVWA](http://cstriker1407.info/blog/use-hydra-brute-kali-dvwa/)

2. [Linux下暴力破解工具Hydra详解](http://www.cnblogs.com/mchina/archive/2013/01/01/2840815.html)

3. [安全盒子 原创:玩Hydra的正确姿势](http://www.secbox.cn/hacker/7497.html)

> hydra: 九头蛇

Hydra v8.3

使用`hydra -h`查看帮助文档. 其中`Supported services:`节包含了支持的模块, 包括ssh, web登录, smb等服务的暴力破解方式, 不同的模块有不同的使用格式.

然后使用`hydra -U 服务类型`查看对应的服务模块的使用帮助. 例如`hydra -U http-post-form`查看post方式的表单验证.

其他选项:

- -l: 指定用户名

- -L: 指定用户名列表文件

- -p: 指定密码

- -P: 指定密码列表文件

- -f: 找到一个正确密码就停止...好像没什么用, 它总是找到一个正确的就停止了...

## 示例

### http-post-form

使用`hydra -U http-post-form`可以得到`http-post-form`的帮助手册. 它的参数选项语法为

```
<url>:<form parameters>:<condition string>[:<optional>[:<optional>]
```

有3个必选域.

其中url为表单提交的url, 一般也是form元素的action地址(使用js完成提交的另说...)

`form parameters`为表单域, 格式为`username=^USER^&password=^PASS^`, `^USER^`与`^PASS^`分别是命令行中指定登录名与密码变量, 也可以直接写成固定字符串, 比如已知登录用户名为admin, 只需要破解密码时可以写成`username=admin&password=^PASS^`.

`condition string`为post请求成功与否的判断条件, 目标为该请求的响应. 默认为失败响应. 比如`...:failed`表示响应字符串中包含'failed'就说明当前用户名:密码对不正确. 等同于`...:F=failed`. 当然, 如果你知道正确密码对的响应, 比如包含'success'字符串的响应即为登陆成功, 可以写成`...:S=success`

```
$ hydra -vV -l admin -P ~/Downloads/1pass00 104.151.231.170 http-post-form "/index.php?s=Admin-Login-Check:user_name=admin&user_pwd=^PASS^:countDownSec"
```

`-l`选项好像重复了???

## 体会

1. hydra的结果不准确, 指定了错误页面中可能出现的关键字的情况下, 指定登录用户却得到错误密码, 甚至多个密码...

2. xhydra: hydra图形界面, 一定程度上可以帮助我们简化命令行的生成

