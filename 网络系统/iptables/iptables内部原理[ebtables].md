参考文章

1. [ebtables基本使用](https://www.cnblogs.com/peteryj/archive/2011/07/24/2115602.html)
    - 神级插图
2. [How to add marks together in iptables (targets MARK and CONNMARK)](https://unix.stackexchange.com/questions/282993/how-to-add-marks-together-in-iptables-targets-mark-and-connmark)
    - iptables链分两种: 内置链(INPUT, OUTPUT, POSTROUTING)和自定义链, 后者只有挂载在前者规则下才可以生效.
    - `ACCEPT/REJECT/DROP`操作会结束整个流程, 而`RETURN`只会结束在当前链的匹配, 这在自定义链中的意义比较特殊.
3. [关于 iptables 和 tc 的限速理解](https://segmentfault.com/a/1190000000666869)
    - iptables&tc实现限速

![](https://gitee.com/generals-space/gitimg/raw/master/b01af23bc2885ae43cc3c1b7be797171.png)

