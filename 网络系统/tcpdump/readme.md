参考文章

1. [linux tcpdump抓取HTTP包的详细解释](https://www.cnblogs.com/zgq123456/p/9878711.html)
    - 参数和表达式解释比较详细
    - 示例很好懂

```
tcpdump -nv -i eth0
```

## 常用表达式

- 地址范围: `host`, `net`, `port`
- 传输方向: `src`, `dst` ,`dst or src`, `dst and src`;
- 协议类型: `ip`, `arp`, `rarp`, `tcp`, `udp`等类型;
- 逻辑运算: 取非运算`not(!)`, 与运算`and(&&)`, 或运算`or(||)`;
- 其他重要的关键字如下：gateway, broadcast,less,greater