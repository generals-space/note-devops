# ps查看进程启动时间及运行时间

参考文章

1. [linux下查看一个进程的启动时间和运行时间](http://www.cnblogs.com/fengbohello/p/4111206.html)

```
## -A表示所有进程, -o表示输出格式(stime: start time, 启动时间; etime: elapsed time, 消逝的时间, 即运行时间, args: 启动命令及参数)
## stime如果超过一年就只能显示年的数字而不能再显示日期, 运行时间可以看到启动的天数和精确到秒级的计算结果
$ ps -A -o pid,stime,etime,args
  PID STIME     ELAPSED COMMAND
    1  2014 846-23:09:53 /sbin/init
11883 Jan29 254-23:59:04 java -Xbootclasspath/a:. -Denv=product
12767 Mar07 216-16:42:12 java -Xbootclasspath/a:. -Denv=product
14552 Jan29 254-23:55:53 java -Xbootclasspath/a:. -Denv=product
15185 Jan29 254-23:55:07 java -Xbootclasspath/a:. -Denv=product
15813  2015 400-00:22:20 java -Xbootclasspath/a:. -Denv=product
```
