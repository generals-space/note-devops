# Shell脚本元素-wait命令

`wait`是bash的内置命令, 作用是, 等待指定进程结束然后返回其退出状态码. 这在shell脚本的多进程实现中颇为有用, 是许多高级语言(c, python等)都实现了的特性.

其语法如下:

```
$ wait 进程pid
$ wait job号
```

> 注意: 这是一个阻塞的方法. 

示例

```
general@ubuntu:~$ ping -c 20 www.baidu.com > /tmp/ping_baidu &
[1] 6913
general@ubuntu:~$ wait 6913 ; echo 'yes'

[1]+  Done                    ping -c 50 www.baidu.com > /tmp/ping_baidu
yes
```

上面的示例中`wait`的参数为pid, 下面的示例则是指定的job id.

```
general@ubuntu:~$ ping -c 20 www.baidu.com > /tmp/ping_baidu &
[1] 6927
general@ubuntu:~$ wait %1 ; echo 'yes'
[1]+  Done                    ping -c 20 www.baidu.com > /tmp/ping_baidu
yes
```

如果不指定参数, 则`wait`将等待所有后台进程执行完毕后才返回.

------

`wait`只能等待其所在终端的子进程的结束, 确切的说, 它只能等待自己的兄弟进程的结束. 即同一终端或是同一脚本内启动的后台进程. 否则会报如下错误.

```
general@ubuntu:/tmp$ wait 6815 ; echo 'yes'
-bash: wait: pid 6815 is not a child of this shell
```