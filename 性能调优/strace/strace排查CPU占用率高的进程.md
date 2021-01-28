# 排查CPU占用率高的进程

参考文章

1. [Linux下分析某个进程CPU占用率高的原因](https://www.cnblogs.com/chenjw-note/p/8370679.html)
    - `strace -p $pid`
2. [strace跟踪线程调用](https://www.cnblogs.com/iot-arking/p/12930349.html)

`strace -p`貌似只跟踪主线程的系统调用信息, 不关心子线程的, 使用`strace -fp`则可以.
