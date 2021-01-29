# Shell-管道与退出码

参考文章

1. [Pipe output and capture exit status in Bash](https://stackoverflow.com/questions/1221833/pipe-output-and-capture-exit-status-in-bash)
    - 与我的场景很相似, 同样是阻塞命令, 需要同时获取其输出结果与退出码
    - `<command> | tee out.txt ; test ${PIPESTATUS[0]} -eq 0`(貌似不适用于`zsh`)
    - `set -o pipefail`(适用于`zsh`)
2. [Bash中的管道输出和捕获退出状态](https://qastack.cn/programming/1221833/pipe-output-and-capture-exit-status-in-bash)
    - 参考文章1的翻译文章
3. [Bash中的管道输出和捕获退出状态](https://blog.csdn.net/asdfgh0077/article/details/104223680)
    - 参考文章1的翻译文章
4. [Get exit code from last pipe (stdin)](https://stackoverflow.com/questions/31805828/get-exit-code-from-last-pipe-stdin)
    - `echo "1" | grep 2 && echo "0" || echo "1"`三元操作符
5. [从最后一个管道（stdin）获取退出代码](https://www.javaroad.cn/questions/291981)
    - 参考文章4的翻译文章

## 场景描述

在用 appium 做自动化测试的时候, 我的脚本在个旧手机上出了问题.

```
WebDriverException("An unknown server-side error occurred while processing the command. Original error: Error getting device API level. Original error: The actual output 'WARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3\r\nWARNING: linker: libset.so: unused DT entry: type 0x6ffffffe arg 0x4518\r\nWARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3\r\n22' cannot be converted to an integer", None, None)
```

我试了下, 原来连接上这个手机, `adb`命令除了`adb devices|disconnect`, 其他的基本都会出问题...

```
root@79a8d22ee501:/app# adb shell getprop ro.build.version.release
WARNING: linker: libset.so: unused DT entry: type 0x6ffffffe arg 0x4518
WARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3
WARNING: linker: libset.so: unused DT entry: type 0x6ffffffe arg 0x4518
WARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3
5.1
root@79a8d22ee501:/app# adb shell getprop ro.build.version.sdk
WARNING: linker: libset.so: unused DT entry: type 0x6ffffffe arg 0x4518
WARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3
WARNING: linker: libset.so: unused DT entry: type 0x6ffffffe arg 0x4518
WARNING: linker: libset.so: unused DT entry: type 0x6fffffff arg 0x3
22
```

不过还是有结果的.

后来对`adb`命令自身的改造(涉及到修改ELF程序格式)失败, 只能想办法把这个问题规避掉, 毕竟结果是可以得到的, 只是 appium 库在解析的时候出了问题. 于是写了如下脚本

```bash
#!/bin/bash
adb.1 $@ | grep -v 'WARNING: linker: libset.so: unused DT entry'
```

将原来的`adb`重命名为`adb.1`, 然后将上述脚本保存为`adb`并赋予执行权限. 如此, 在执行`adb`相关的命令时, 就会把这种输出过滤掉.

重新运行程序, 结果又报了如下错误

```
2020-12-19 03:11:30,865 ERROR - main.py:19 - WebDriverException("An unknown server-side error occurred while processing the command. Original error: Error waiting for the device to be available. Original error: 'Error executing adbExec. Original error: 'Command '/root/platform-tools/adb -P 5037 -s 192.168.31.51\\:5555 wait-for-device' exited with code 1'; Stderr: ''; Code: '1''", None, None)
```

我试了试, 直接执行`adb.1 $@ | grep -v 'WARNING: linker: libset.so: unused DT entry'`原来返回码真的是`1`...

## 解决方法

由于管道前后两句都没有问题, 那就只能是管道本身与退出码的问题了.

`echo "1" | grep 2`这样的命令的返回码是`grep 2`的结果, 比如

```console
$ echo 123 | grep -v 123
$ echo $?
1
```

但一般我们的目标是前半部分的结果, 按照参考文章1和4, 有如下几种方案可以选择

```bash
echo 123 | grep -v 123; test ${PIPESTATUS[0]} -eq 0
echo 123 | grep -v 123 && echo 0 || echo 1
set -o pipefail
```

推荐是第1种, 因为第2种有额外的输出(0或1), 有可能会影响之后的判断, 第3种没尝试.

关于`PIPESTATUS`, `$PIPESTATUS[0]`保存管道中第一个命令的退出状态, `$PIPESTATUS[1]`保存第二个命令的退出状态, 依此类推(`$PIPESTATUS[-1]`为最后一个管道命令的状态).

