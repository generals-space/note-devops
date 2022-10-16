# Apache-Uninterruptible Sleep[webbench http top]

## 情境描述

- 服务器: Fedora 22 512M
- Apache 2.4
- php5, Mysql

webbench命令: `webbench -c 500 -t 60 http://172.16.171.132/`

在用webbench对Apache上运行的 wordpress 进行压力测试时, 500的并发量让服务器内存居高不下, 负载持续处于120+.

用top查看httpd服务的进程状态, S字段罕见的出现了"D", top手册上说明这是`uninterruptible sleep`(不可中断的睡眠), 一般出现在陷入内核态后等待IO时出现. 甚至无法用root身份kill掉. 只能重启.

现阶段首先去完成服务器集群的搭建, 留一些疑问在这里:

- uninterruptible sleep 是什么? 何时出现?
- 如何事先避免?
- webbench如何使Apache陷入这种状态? 是否可以应用为泛洪攻击? (研究webbench源码)
- 这是内核的失误还是Apache的不足?

留一些链接:

http://stackoverflow.com/questions/223644/what-is-an-uninterruptable-process#new-answer

http://blog.xupeng.me/2009/07/09/linux-uninterruptible-sleep-state/

http://www.orczhou.com/index.php/2010/05/how-to-kill-an-uninterruptible-sleep-process/
