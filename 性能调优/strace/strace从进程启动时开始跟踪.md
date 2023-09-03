# strace从进程启动时开始跟踪

参考文章

1. [Using strace to trace a process that is yet to start](https://www.reddit.com/r/commandline/comments/2oqejj/using_strace_to_trace_a_process_that_is_yet_to/)

`strace`常规的使用方法是指定一个pid, 追踪一个正在运行的进程的系统调用.

```
strace -p $PID
```

但有时候我想追踪某个进程在启动时的行为, 怎么办?

可以使用`strace`启动目标进程, 如下

```
strace ./xxx
```
