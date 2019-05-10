
参考文章

1. [初探BeEF](http://blog.csdn.net/emaste_r/article/details/17091067)

2. [Kali下beEF关联metasploit的攻击模块](http://www.metasploit.cn/thread-761-1-1.html)

3. [kali Linux系列教程之BeFF安装与集成Metasploit](http://www.cnblogs.com/xuanhun/p/4203143.html)

## 1. 关于beef

初步认为, beef就是一个钓鱼页面...没错我就是这么认为

使用场景就是, 你在论坛里发贴, 发链接, 引诱用户来点击, 只要有用户访问, 就可以通过beef的一个'恶意'的`hook.js`获取访问者的信息.

hook.js包含了部分探针方法. 可以检测访问用户的各种数据, 如user-agent, 浏览器版本, 来访者IP, 是否启用Java控件等, 并且很有可能获取用户cookie.

## 2. 使用方法

Kali2默认安装了beef, 可执行文件在`/usr/share/beef-xss/beef`, Kali提供一个便捷脚本`beef-xss`, 可以直接在命令行中调用, 但需要在图形界面环境下使用. 因为它启动beef后还会自动调用浏览器打开beef的web管理界面.

beef的管理地址为`127.0.0.1:3000/ui/panel`, 用户名和密码都是beef.

## 3. 与metasploit结合

```
msf > load msgrpc ServerHost=172.32.100.40 Pass=abc123
[*] MSGRPC Service:  172.32.100.40:55552 
[*] MSGRPC Username: msf
[*] MSGRPC Password: abc123
[*] Successfully loaded plugin: msgrpc
msf > 
```