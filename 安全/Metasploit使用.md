# 

参考文章

1. [Kali Linux渗透基础知识整理（三）：漏洞利用](http://www.freebuf.com/sectool/109955.html)

2. [Metasploit渗透测试魔鬼训练营 1.6.2节](#)

`msfupdate`: 更新

metasploit依赖postgresql数据库, Kali下默认已经安装, 确认`postgresql`服务已经启动. 然后输入`msfconsole`打开控制台.

```
## 搜索可用的目标模块
msf > search pureftp
## 选择
msf > use xxx
## 查看与之匹配的payload
msf > show payloads
## 设置payloads
msf > set payload xxx
## 查看需要配置的选项
msf > show options
## 设置必选选项
msf > set RHOST xxx.xxx.xxx.xxx
## 执行攻击
msf > exploit
```
