# 服务器安装CentOS7未检测到硬盘的处理方法

参考文章

1. [HP服务器 hp 360g5 centos7安装问题](https://www.cnblogs.com/kunchong21/p/6209335.html)

2. [解决HP ProLiant DL380 G5的CentOS 7安装与启动不能识别硬盘问题](http://www.linuxidc.com/Linux/2016-07/133089.htm)

3. [HP服务器安装CentOS7 x64无法识别硬盘解决](http://www.linuxidc.com/Linux/2016-07/133086.htm)

> 服务器型号: HP ProLiant DL360 G5

从U盘引导启动, 选择语言, 然后配置安装盘, 显示如下

![](https://gitee.com/generals-space/gitimg/raw/master/ea6b03b539a1c168792688da9374c86f.jpg)

...服务器上没法截图, 只能拍个照.

`Local Standard Disks`中只显示了U盘本身, 没有显示服务器硬盘.

按照参数文章3中所说, `HP 360G5`在安装和启动时要加内核参数. 具体如下

1. 在进入安装引导界面时, 用上下键选择安装centos——Install Centos7（注意不可按Enter键），如图：

![](https://gitee.com/generals-space/gitimg/raw/master/baec675684c824bc5017d279c3df98ac.png)

2. 按Tab键，对安装进行额外配置，在屏幕最下方会显示如下字样：

![](https://gitee.com/generals-space/gitimg/raw/master/9e639b954c5f9d2891aff7ce49f94f55.png)

3. 在额外配置的命令行上添加配置： `hpsa.hpsa_simple_mode=1 hpsa.hpsa_allow_any=1`, 空格分隔, 没有换行. 如图所示：

![](https://gitee.com/generals-space/gitimg/raw/master/b2287135403542e3132af02ebd5f46b4.png)

3. 按回车继续安装

经过以上几步，安装程序即可识别出HP服务器的硬盘。

上面要加的两句是内核参数, `HP 360 G5`最好再加上`biosdevname=0`和`net.ifnames=0`两句(`ifnames`那句是将网卡变为`eth0`). 一共是

`hpsa.hpsa_allow_any=1 hpsa.hpsa_simple_mode=1 biosdevname=0 net.ifnames=0`. 其实这两句对安装与启动没有影响, 只不过安装好CentOS7后很多时候网卡名变的很怪异, 像`em0`, `ens`什么的, 后面两句只是为了标准化一下.

参考文章1, 2都参考了文章3, 文章3到这里就没了, 但实际上还没完.

------

安装完成启动后, 系统进入了`dracut`命令行, 显示为

```
dracut:/#
```

网上的解释说这是因为系统启动时没有找到正确的`ramfs`, 参考文章1和2都给出了后续操作的补充方法.

首先我们要先保证能正常进入系统.

重启服务器, 在进入`grub`引导界面时, 将光标上下移动一下, 不要让它自动跳过, 如下

![](https://gitee.com/generals-space/gitimg/raw/master/43ef78172225a8300bd8e77edbcd4d05.png)

按下`e`进入编辑状态, 同样键入`hpsa.hpsa_simple_mode=1 hpsa.hpsa_allow_any=1`参数, 然后按下`Ctrl+X`可正常引导.

> 注意, 按`e`进入编辑状态后文本可能有点长, 找到`CentOS 7(Core)`那一段, 在`quiet`后接着写就成了.

------

进入系统后, 我们还要让刚才的引导配置永久生效, `root`用户编辑`/boot/grub2/grub.cfg`文件, 在与上面启动时编辑状态相同的位置写下那两句参数配置即可. 如下

![](https://gitee.com/generals-space/gitimg/raw/master/534baa426e4aefe0ae297c035520aa25.png)
