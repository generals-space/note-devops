# awk.3.格式化输出[print printf]

参考文章

1. [awk 格式化输出](https://blog.csdn.net/shangboerds/article/details/49465925)
   - printf("格式化字符串", 参数列表). 详细介绍了宽度, 精度, 左对齐等选项
   - sprintf()
2. [优雅地输出](https://wiki.jikexueyuan.com/project/awk/pretty-printing.html)
   - printf "格式化字符串", 参数列表

`awk.txt`

```
SYN_RECV 798
ESTABLISHED 2444
FIN_WAIT1 2
TIME_WAIT 3982
```

## 普通`print`的输出

```log
$ awk '{print $1, $2}' awk.txt
SYN_RECV 798
ESTABLISHED 2444
FIN_WAIT1 2
TIME_WAIT 3982
```

## `printf`实现左对齐输出

```log
$ awk '{printf("status: %-15s sum: %d\n", $1, $2)}' awk.txt
status: SYN_RECV        sum: 798
status: ESTABLISHED     sum: 2444
status: FIN_WAIT1       sum: 2
status: TIME_WAIT       sum: 3982
```
