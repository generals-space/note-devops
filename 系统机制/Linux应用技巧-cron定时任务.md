# Linux应用技巧-cron定时任务

参考文章

1. [如何用shell查询每个用户定时任务？](https://segmentfault.com/q/1010000005340196)

## 1. 书写格式

执行`crontab -l`可以查看当前用户的定时任务列表, `crontab -e`可以编辑当前用户的过时任务

任务列表最终保存在`/var/spool/cron`, 以每个用户的用户名为名称.

```
## 其中命令应该写绝对路径
分　 时　 日　 月　 周　 命令
```

第1列表示第几分钟(1～59), 每分钟用`*`或者`*/1`表示

第2列表示第几小时(0～23),（0表示0点）, 同理每分小时为`*`或者`*/`

第3列表示日期(1～31)

第4列表示月份(1～12)

第5列表示号星期(0～6)（0表示星期天）

第6列要运行的命令, 可以有空格

示例

```
#每晚的21:30重启lighttpd。
30 21 * * * /usr/local/etc/rc.d/lighttpd restart
#每月1、10、22日
45 4 1,10,22 * * /usr/local/etc/rc.d/lighttpd restart
#每天早上6点10分
10 6 * * * date
#每两个小时
0 */2 * * * date
#晚上11点到早上8点之间每两个小时，和早上8点...有点复杂
0 23-7/2,8 * * * date
#每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点
## ...这个更复杂, 月份中的日期与星期中的日期貌似不冲突, 小时数相同时竟然可以共用
0 11 4 * 1-3 date
#1月份第天早上4点
0 4 1 * * date 
```

很多时候，我们计划任务需要精确到秒来执行，根据以下方法，可以很容易地以秒执行任务。
以下方法将每10秒执行一次

```
# crontab -e
* * * * * /bin/date >>/tmp/date.txt
* * * * * sleep 10; /bin/date >>/tmp/date.txt
* * * * * sleep 20; /bin/date >>/tmp/date.txt
* * * * * sleep 30; /bin/date >>/tmp/date.txt
* * * * * sleep 40; /bin/date >>/tmp/date.txt
* * * * * sleep 50; /bin/date >>/tmp/date.txt
```
 
注意如果用如果命令用到%的话需要用`\`转义

```
# mysql备份
00 01 * * * mysqldump -u root --password=passwd-d mustang > /root/backups/mustang_$(date +\%Y\%m\%d_\%H\%M\%S).sql
01 01 * * * mysqldump -u root --password=passwd-t mustang > /root/backups/mustang-table_$(date +\%Y\%m\%d_\%H\%M\%S).sql
```

## 2. 权限控制

crontab 用来任务定时调度，在Linux下可以通过创建文件`/etc/cron.allow`或者`/etc/cron.deny` 
来控制权限，如果`/etc/cron.allow`文件存在，那么只有这个文件中列出的用户可以使用`cron`，同时 
`/etc/cron.deny`文件被忽略； 如果`/etc/cron.allow`文件不存在，那么文件`/cron.deny`中列出的用户将不能用使用`cron`。

添加要限制的用户，只需要写入用户名即可。

## 3. 查看指定用户的定时任务

`crontab -l -u 用户名`: root用户可以使用这条命令查看指定用户的定时任务.

默认没有提供查询所有用户crontab的功能...没办法, `-u`参数不接受通配符. 但是可以查看`/var/spool/cron`目录下拥有(或是曾经拥有)crontab的所有用户, 你可以通过`cat /var/spool/cron/*`全部输出... 