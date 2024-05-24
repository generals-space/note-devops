# netstat --wide禁止输出截断

参考文章

1. [Netstat output line width limit](https://unix.stackexchange.com/questions/212096/netstat-output-line-width-limit)

```log
$ netstat -anopt
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name     Timer
tcp6       0      0 :::37949                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::36513                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 ::1:8005                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8080                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8081                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8084                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 2409:808e:4980:31:37900 2409:808e:4980:734:2181 TIME_WAIT   -                    timewait (50.83/0/0)
tcp6       0      0 2409:808e:4980:31:41044 2409:808e:4980:734:2181 TIME_WAIT   -                    timewait (0.00/0/0)
tcp6       0      0 2409:808e:4980:31:37822 2409:808e:4980:734:2181 TIME_WAIT   -                    timewait (38.96/0/0)
tcp6       0      0 2409:808e:4980:31:35708 2409:808e:4980:734:2181 TIME_WAIT   -                    timewait (36.18/0/0)
```

某次使用 netstat 查看网络连接的时候, 发现输出的结果中 IP 是非法的. 如"2409:808e:4980:734"根据ping不通.

> 注意: 不是因为多了`-o`参数导致每行变长, 去掉该选项也是一样的.

可以添加`--wide`参数解决

```log
$ netstat -anopt --wide
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name     Timer
tcp6       0      0 :::37949                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::36513                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 ::1:8005                :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8080                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8081                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 :::8084                 :::*                    LISTEN      24/java              off (0.00/0/0)
tcp6       0      0 2409:808e:4980:310:c8c7:413a:32d1:6794:43456 2409:808e:4980:734:1::4f:2181 TIME_WAIT   -   timewait (15.57/0/0)
tcp6       0      0 2409:808e:4980:310:c8c7:413a:32d1:6794:41568 2409:808e:4980:734:1::60:2181 TIME_WAIT   -   timewait (38.81/0/0)
tcp6       0      0 2409:808e:4980:310:c8c7:413a:32d1:6794:41436 2409:808e:4980:734:1::60:2181 TIME_WAIT   -   timewait (24.40/0/0)
tcp6       0      0 2409:808e:4980:310:c8c7:413a:32d1:6794:43630 2409:808e:4980:734:1::4f:2181 TIME_WAIT   -   timewait (36.98/0/0)
```
