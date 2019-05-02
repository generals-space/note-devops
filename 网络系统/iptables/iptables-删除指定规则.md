# iptables-删除指定规则

参考文章

1. [iptables删除指定某条规则](http://www.111cn.net/sys/linux/58445.htm)

2. [iptables详解](http://blog.chinaunix.net/uid-26495963-id-3279216.html)

首先要查看规则, 获取其行号

```
$ iptables [-t nat] -vnL --line-number
```

- `-t`: 选择table类型, 默认显示filter, 可以显示其他如nat类型的
- `-L`: 不用说了
- `-v`: 输出详细信息, 包括通过该行所示规则的数据包数量, 总字节数及相应的网络接口
- `-n:` 不对IP地址进行反查, 加上这个参数显示速度会快很多, 否则iptables会把规则中它已知的IP都替换成域名的
- `--line-number`: 显示规则的序列号，这个参数的输出在删除或修改规则时会用到

然后删除指定行号代表的规则.

```
$ iptables [-t nat] -D INPUT 行号
```

- `-D` 删除指定规则, 后面需要接chain名与行号参

------

与之操作相似的有

- `-I 链名 n`: 插入，把当前规则插入为第n条。

```
## 插入为INPUT链的第三条
$ iptables -I INPUT 3 目标规则
```

- `-R 链名 n`: Replace替换/修改第n条规则

```
## 将INPUT的第3条规则修改为如下
$ iptables -R INPUT 3 目标规则
```

- `-D 链名 n`: 删除，明确指定删除目标链上的第n条规则