参考文章

1. [Problem using ssh with crontab](https://unix.stackexchange.com/questions/296582/problem-using-ssh-with-crontab)
2. [解决Linux关闭终端（关闭SSH等）后运行的程序或者服务自动停止【后台运行程序】](https://freesilo.com/?p=577)
3. [如何可靠地保持SSH隧道打开？](https://qastack.cn/superuser/37738/how-to-reliably-keep-an-ssh-tunnel-open)

在命令行执行`ssh forward`可以成功, 但是通过crontab来执行就总是会被终止. 

不是环境变量的问题, 尝试过加载`/etc/profile`和`~/.bashrc`, 无效.

加过`&`, 也试过`nohup`, 都不行.

我觉得参考文章1中给出的猜想应该是正确的, 于是在`ssh forward`后加了一句远程命令`tail -f /etc/os-release`, 阻塞住ssh进程不被杀死, 有效.

`flush_dns.sh`是MacOS下刷新`nat.generals.space`域名解析的脚本.
