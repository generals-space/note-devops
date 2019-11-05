# iptables查看否条规则是否存在

参考文章

1. [How can I check if an iptables rule already exists?](https://superuser.com/questions/360094/how-can-i-check-if-an-iptables-rule-already-exists)

iptables有一个`-C/--check`选项, 语法如下

```
iptables [-t 表名] -C 链名 规则语句
```

ta通过退出码返回检测结果, 0表示存在, 1则表示不存在, 同时会有如下输出

```
iptables: Bad rule (does a matching rule exist in that chain?).
```

具体使用方法可以查看man手册.

## 使用示例

```
iptables -t filter -C FORWARD -s 10.254.0.0/16 -j ACCEPT
```
