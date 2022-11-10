# awk获取所有网络连接状态总量

```console
$ netstat -an
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:3001            0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:3002            0.0.0.0:*               ESTABLISHED
...
```

- `/^tcp/`: 过滤以tcp开头的行
- `S`: 可看作一个字典(看来不用初始化), 键名为`LISTEN`, `ESTABLISHED`这种.
- `NF`: Number of Fileds. awk内置变量, 表示当前输入行中的字段个数. $NF表示最后一列的字段的值.
- `++S[$NF]`: 如果$NF的值为`LISTEN`, 则`S[LISTEN]`加1, 其他类型同理, 用于计数.
- `END {actions}`: 在处理完所有行(将不同状态的连接归类汇总)后, 执行actions操作.
- `for(a in S) print a, S[a]`: 循环打印`S`字典中不同状态的名称`a`及汇总数据`S[a]`, 将会按`a`进行排序.

```console
$ netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
ESTABLISHED 9330
SYN_SENT 670
TIME_WAIT 1
```

添加上格式化输出会顺眼一些

```console
$ netstat -an | awk '
/^tcp/ {++S[$NF]} 
END {
    for(a in S) printf("status: %-15s sum: %d\n", a, S[a])
}
'
status: LISTEN          sum: 1
status: SYN_RECV        sum: 142
status: ESTABLISHED     sum: 9003
status: TIME_WAIT       sum: 112
```

`watch -n 1 "netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) printf(\"status: %-15s sum: %d\n\", a, S[a])}'"`
