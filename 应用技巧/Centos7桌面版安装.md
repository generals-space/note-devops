# Centos7桌面版安装

<!key!>: {c2f8cf90-5387-11e9-ae66-aaaa0008a014}

<!link!>: {664fdd98-537c-11e9-b398-aaaa0008a014}

参考文章

1. [CentOS-7-x86_64-DVD-1810安装之后无法切换到图形界面](https://blog.csdn.net/weixin_39753511/article/details/85337373)

想在虚拟机中安装图形界面的centos7, 在官网上下载了DVD版的iso镜像(4点多个G), 按照链接文章中的说明, 使用`systemctl set-default graphical.target`设置开机进入图形界面, 但是重启后进入的仍然是字符界面.

之后找到了参考文章1, 在安装过程中我大多将设置保留为默认, 但是默认是minimal安装, 不会包含图形界面服务, 需要手动选择.

![](https://gitee.com/generals-space/gitimg/raw/master/9908929de3075c065785e7e52564f64e.png)

默认为minimal安装, 要启动图形界面, 还需要选择`gnome`或`kde`环境(单选).

![](https://gitee.com/generals-space/gitimg/raw/master/1767b53a2910855bcb4e01ddfc675afa.png)

如果选择gnome, 安装完成后会得到如下界面

![](https://gitee.com/generals-space/gitimg/raw/master/2a60359f1d8a0bd8fee65c971be7d04b.png)

<!--
如果选择kde, 则会是这样

![](https://gitee.com/generals-space/gitimg/raw/master/1767b53a2910855bcb4e01ddfc675afa.png)
-->
