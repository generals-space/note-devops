# iptables-state模块

参考文章

1. [iptables的state模块的4种封包链接状态](http://blog.csdn.net/jeremy_yangt/article/details/48323109)
    - 描述简单易懂
2. [iptables conntrack和state的区别](http://blog.chinaunix.net/uid-27057175-id-5119553.html)
    - 列举各个参考来源以确定两者关系
3. [iptables详解（8）：iptables扩展模块之state扩展](http://www.zsythink.net/archives/1597)
    - 文章开始的提出的场景不要考虑`tcp`模块的`dport/sport`, 按照文章本身的思路来.
    - 关于RELATED的解释不太好, 不过有一句可以借鉴一下: "如果你还不放心, 可以将状态为RELATED或ESTABLISHED的报文都放行"

iptables中存在两个state模块: `state`和`conntrack`. 按照参考文章2所说, `state`模块日后将被废弃, 尽量使用`conntrack`.

```
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

数据包的链接状态有4种:

- `ESTABLISHED`
- `NEW`
- `RELATED`
- `INVALID`

