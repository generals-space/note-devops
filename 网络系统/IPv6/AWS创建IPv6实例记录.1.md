# AWS创建IPv6实例记录

参考文章

1. [手把手教你如何在AWS EC2 启用 IPv6](https://www.jianshu.com/p/131409434cec)
2. [亚马逊AWS EC2如何开启ipv6](https://blog.51cto.com/dellinger/2134119)
3. [亚马逊aws开启ipv6的方法图解](https://www.pcwanjia.com/html/2019/08/244.html)
4. [AWS EC2如何从普通用户切换为root用户](https://blog.csdn.net/tanhongwei1994/article/details/88657452)
    - `ec2-user`普通用户 -> `root`: 执行`sudo -s`即可, 无需输入密码.

## 写在前面

日期: 20200603

阿里云, 腾讯云, 金山云的 IPv6 都处在测试阶段, 需要申请才能使用. 国内运营商的 IPv6 推行的进度还是太慢, 想起来了还有国外的云厂商, 微软Azure, 亚马逊AWS 和谷歌(不过需要绑定信用卡, 没法支付宝付费).

