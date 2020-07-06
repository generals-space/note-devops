# Linux源与镜像源配置分析.2.apt

参考文章

1. [关于ubuntu的sources.list总结](http://www.cnblogs.com/jiangz/p/4076811.html?utm_source=tuicool&utm_medium=referral)
2. [ubuntu添加ppa源(个人软件包集)简单方法](http://www.jbxue.com/LINUXjishu/26993.html)

apt的配置文件在 `/etc/apt`目录下, 虽然文件名不一样, 但配置结构与CentOS相似, `source.list`文件相当于`yum.conf`为主配置文件, `source.list.d/*.list`相当于`yum.conf.d/*.conf`文件. 不过 `source.list`没有那么多配置选项, 貌似都是直接上url地址.

以ubuntu14.04下的`source.list`为例.

```shell
# deb cdrom:[Ubuntu 14.04.1 LTS _Trusty Tahr_ - Release amd64 (20140722.2)]/ tru
sty main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted
```

每一行的开头是`deb`或者`deb-src`, 分别表示直接通过.deb文件进行安装和通过源文件的方式进行安装.

deb或者deb-src字段之后, 是一段URL, 之后是五个用空格隔开的字符串, 分别对应相应的目录结构. 在浏览器中输入http://mirrors.aliyun.com/ubuntu/, 并进入dists目录, 可以发现有5个目录和前述sources.list文件中的第三列字段相对应. 任选其中一个目录进入, 可以看到和sources.list后四列相对应的目录结构.

更多内容可以使用man source.list获得.

------

**关于`ppa(personal package archives)`, 个人软件包集.**

当由于种种原因, 不能进入官方的ubuntu软件仓库时, 为方便ubuntu用户使用, launchpad.net提供了ppa, 允许用户建立自己的软件仓库, 自由的上传软件.

ppa也被用来对一些打算进入ubuntu官方仓库的软件, 或者某些软件的新版本进行测试.

launchpad是ubuntu母公司canonical有限公司所架设的网站, 是一个提供维护、支援或联络ubuntu开发者的平台. 在[launchpad](https://launchpad.net/ubuntu/)中查找官方源中不提供的软件包.

然后添加ppa源

```shell
sudo add-apt-repository ppa:user/ppa-name
```

你会在`source.list.d`目录下看到包含`ppa`串的刚添加的ppa源. 接着更新源, 再安装即可

```shell
sudo apt-get update
sudo apt-get install 你想要的软件包
```
