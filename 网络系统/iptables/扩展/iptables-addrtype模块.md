# iptables-addrtype模块

参考文章

1. [使用netfilter/iptables时经常能在匹配规则中看到-m addrtype --dst-type这样的内容，何解](https://blog.csdn.net/watermelonbig/article/details/80319766)
    - `conntrack`与`state`模块的`RELATED,ESTABLISHED`功能貌似相同
    - 说明了`addrtype`的扩展的功能, 解释了`-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER`的作用.
2. [What are the definitions of addrtype in iptables?](https://unix.stackexchange.com/questions/130807/what-are-the-definitions-of-addrtype-in-iptables)
3. [iptables: what does “--src-type LOCAL” mean exactly?](https://serverfault.com/questions/193560/iptables-what-does-src-type-local-mean-exactly/979903)

```
-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
```

参考文章1详细解释了上述语句使用`addrtype`完成的功能, 但是`man iptables-extensions`手册中对于`--dst-type`的具体类型只有一句概念声明, 没有示例. 

参考文章2中的提问者给出了相关的猜想, 比如`LOCAL`类型可能并不单指`127.0.0.1/8`, `MULTICAST`可能指`224.0.0.0/4`等.

但是关于这个问题并没有明确的答案, 也许需要更加专业的计算机网络知识才能理解, 这里先略过.
