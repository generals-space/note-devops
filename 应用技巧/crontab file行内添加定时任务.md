# crontab file行内添加定时任务

参考文章

1. [使用shell脚本或命令行 添加crontab 定时任务](https://blog.csdn.net/mzc11/article/details/81842534)

crontab 是运维过程中常用的定时任务执行工具, 一般情况下在有新的定时任务要执行时, 使用crontab -e , 将打开一个vi编辑界面, 配置好后保存退出.

但是在自动化运维的过程中往往需要使用shell脚本或命令自动添加定时任务, 接下来介绍三种（Centos）自动添加`crontab`任务的方法.

## 方法一

编辑`/var/spool/cron/用户名`文件, 如：

```bash
echo "* * * * * hostname >> /tmp/tmp.txt" >> /var/spool/cron/root
```

优点：简单

缺点：需要root权限

## 方法二

编辑`/etc/crontab`文件,

```bash
echo "* * * * * root hostname >> /tmp/tmp.txt" >> /etc/crontab
```

需要注意的是, 与常用的crontab 有点不同, `/etc/crontab`需指定用名. 而且该文件定义为系统级定时任务, 不建议添加非系统类定时任务, 编辑该文件也需要root权限.

## 方法三：

利用`crontab -l`加`crontab file`两个命令实现自动添加

```bash
crontab -l > conf && echo "* * * * * hostname >> /tmp/tmp.txt" >> conf && crontab conf && rm -f conf
```

由于`crontab file会`覆盖原有定时任务, 所以使用`crontab -l`先导出原有任务到临时文件"conf"再追加新定时任务

优点：不限用户, 任何有crontab权限的用户都能执行

缺点：稍微复杂
