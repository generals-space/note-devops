参考文章

1. [linux tcpdump抓取HTTP包的详细解释](https://www.cnblogs.com/zgq123456/p/9878711.html)
    - 参数和表达式解释比较详细
    - 示例很好懂
2. [聊聊 tcpdump 与 Wireshark 抓包分析](https://mp.weixin.qq.com/s?__biz=MzAxODI5ODMwOA==&mid=2666539134&idx=1&sn=5166f0aac718685382c0aa1cb5dbca45&scene=5&srcid=0527iHXDsFlkjBlkxHbM2S3E#rd)
3. [聊聊 tcpdump 与 Wireshark 抓包分析](https://www.jianshu.com/p/8d9accf1d2f1)
    - 参考文章2的转载文章

```
tcpdump -nv -i eth0
```

## 常用表达式

- 地址范围: `host`, `net`, `port`
- 传输方向: `src`, `dst` ,`dst or src`, `dst and src`;
- 协议类型: `ip`, `arp`, `rarp`, `tcp`, `udp`等类型;
- 逻辑运算: 取非运算`not(!)`, 与运算`and(&&)`, 或运算`or(||)`;
- 其他重要的关键字如下：gateway, broadcast,less,greater

