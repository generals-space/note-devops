# AWS创建IPv6实例记录

参考文章

1. [手把手教你如何在AWS EC2 启用 IPv6](https://www.jianshu.com/p/131409434cec)
    - VPC, Subnet, Security Groups(安全组), Routing Tables(路由表), EC2(虚拟机)
2. [亚马逊AWS EC2如何开启ipv6](https://blog.51cto.com/dellinger/2134119)
3. [亚马逊aws开启ipv6的方法图解](https://www.pcwanjia.com/html/2019/08/244.html)
4. [AWS EC2如何从普通用户切换为root用户](https://blog.csdn.net/tanhongwei1994/article/details/88657452)
    - `ec2-user`普通用户 -> `root`: 执行`sudo -s`即可, 无需输入密码.

## 写在前面

日期: 20200603

阿里云, 腾讯云, 金山云的 IPv6 都处在测试阶段, 需要申请才能使用. 国内运营商的 IPv6 推行的进度还是太慢, 想起来了还有国外的云厂商, 微软Azure, 亚马逊AWS 和谷歌(不过需要绑定信用卡, 没法支付宝付费), 这里以AWS为例, 新用户有12个月的免费期, 正好来试试手.

## 过程

创建好AWS账号后, 首先创建支持 IPv6 的 VPC 网络. 默认已经有了一个, 所以我们只需要在"操作"菜单中选择"Edit CIDRs"即可, 如下图.

![](https://gitee.com/generals-space/gitimg/raw/master/ECD71A7303C2DF4694E9C01CF4736167.png)

AWS支持为 VPC 默认分配一个 IPv6 网段, 上图中我已经分配好了, 掩码位56. 保存后返回, 可看到结果如下

![](https://gitee.com/generals-space/gitimg/raw/master/95277213744B9BA9EBA9D07B092BC3DF.png)

每个 VPC 下可以支持 n 个子网, 默认有3个. 

![](https://gitee.com/generals-space/gitimg/raw/master/85853BDC8F5C4C112CB6CF8882C69710.png)

这里我选取了`172.31.32.0/20`这个网段, 为 ta 添加 IPv6 网段. 

![](https://gitee.com/generals-space/gitimg/raw/master/C00523B18756D45DC2541D3CD9053DAB.png)

不清楚这里的网段与 VPC 上的网段有什么关系, 子网在分配网段时要填两位数字. 参考文章1中写到, 按照创建的 IPv6 序号, 从 00 开始写就可以, 之后再创建时, 就写 01, 02...这里我也写了 00. 保存后返回, 可看到如下结果.

![](https://gitee.com/generals-space/gitimg/raw/master/2FF7DBEF089A18BA126B908D30921DE4.png)

接下来是创建实例, 安全组的部分在创建实例的过程中有提到.

AWS创建实例的流程与阿里云有点不一样, 要先选系统镜像, 再选机器规格. 且ta提供的镜像中没有CentOS, 只有Redhat. 我选了Redhat, 这一步忘记截图了...

然后是选取机器规格, 在免费期只有一种规格可用.

![](https://gitee.com/generals-space/gitimg/raw/master/528E07E0DC4EF75C33CE769626C95FDE.png)

再然后是配置过程, 有点长我截了两个图.

![](https://gitee.com/generals-space/gitimg/raw/master/FE875325AA281F34DDDB2F3FFA45A832.png)

![](https://gitee.com/generals-space/gitimg/raw/master/8613C2C85344D36647CB729D8B0568D1.png)

注意有几个注意点, 网络/子网选择我们上面添加过 IPv6 支持的, "网络接口"一节中, 添加一个公网 IPv6 地址, 由 AWS 自动分配.

接下来是配置安全组.

![](https://gitee.com/generals-space/gitimg/raw/master/1FF16BB66DF69F8FDBD01138445387FA.png)

这个其实有点不太够的, 因为没加 IPv4 的 ICMP 允许, 导致直接 ping 分配的 IPv4 地址是不通的, 查了老半天. 后来我又更新过, 结果如下.

![](https://gitee.com/generals-space/gitimg/raw/master/C716E50B63F75171F10C7BF1657C8CC7.png)

之后会让你填写一下要使用的密钥, 我找了找, 没找到可以上传自己公钥的地方, 只能让ta在线生成了一个, 然后下载下来.

至此 EC2 主机创建完成.

------

忘了, 还有一个路由表的事.

之前忘记添加路由表记录, 结果从主机上只能 ping 通 IPv4 的域名, 无法 ping 通 google, youtube 这些(后来想想, 这个网站必然有双栈设计, DNS的解析结果都是 IPv6), 还需要添加对外部 IPv6 地址的访问. 

![](https://gitee.com/generals-space/gitimg/raw/master/9CB738916E825812BFCF190C4974109F.png)

路由表可以说是与安全组相反的东西, ta控制出口请求, 默认放行了对内网, 对所有 IPv4 网络的访问, 没有放行对 IPv6 网络的访问.

## EC2 试用

不过登录的时候遇到点麻烦.

首先是下载下来这个新私钥的权限, 需要是400/600, 不能太高.

然后是登录用户不是root, 也不是密钥名称, 用这些登录都失败了...网上查了半天才发现貌似有特定的名称, 叫`ec2-user`.

于是登录命令变成了

```
ssh -i general.pem ec2-user@EC2的公网IP
```

而且在我本地竟然还登不上(但能 ping 通, 神了), 最后又找了一台阿里云的主机, 当了个跳板才登上去的.

![](https://gitee.com/generals-space/gitimg/raw/master/9658563C7D009E5BD157B3D98AF6FA46.png)

EC2 分配的公网 IPv4 地址在命令行是查看不到的, 但是分配的公网 IPv6 是有的.

`ec2-user`普通用户 -> `root`: 执行`sudo -s`即可, 无需输入密码.
