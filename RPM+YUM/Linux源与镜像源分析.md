# Linux源与镜像源分析(待整理)

<!tags!>: <!linux应用技巧!>

## 1. 引言

本文只涉及CentOS/Fedora系和Debian/Ubuntu系的在线包管理机制, 其他的Linux发行版没有使用过.

源(source)即是Linux发行版的软件仓库(repository)的 **url地址**. 软件仓库其实是http/ftp站点, CentOS/Fedora与Debian/Ubuntu分别通过yum(dnf)与apt进行软件 **在线管理**. 通过url确定站点地址, 通过系统版本号等信息确定路径, 到指定的仓库查询目标软件.

不同的源之间的区别主要在于, **访问速度的快慢**与**包的种类是否全面**. 我觉得这也是问题的根源, 因为这会引起人们对源的寻找与包的导入, 通常会遇见各种奇怪的问题.

## 2. CentOS/Fedora

参考文章

[CentOS yum 源的配置与使用](http://www.cnblogs.com/mchina/archive/2013/01/04/2842275.html)

yum 的配置文件分为两部分: `main`和`repository`

- main 部分定义了全局配置选项, 整个yum 配置文件应该只有一个main. 常位于/etc/yum.conf 中.

- repository 部分定义了每个源/服务器的具体配置, 可以有一到多个. 常位于/etc/yum.repo.d 目录下的各文件中.

`yum.conf`文件中的详细配置见附录, 在正文中不占用篇幅. 主要是`/etc/yum.repo.d`下的 `.repo`文件.

`.repo`文件通常呈如下格式,

```shell
[serverid]
name=Some name for this server
baseurl=url://path/to/repository/
```

- serverid 是用于区别各个不同的repository, 必须有一个独一无二的名称;

- name 是对repository 的描述, 支持像$releasever $basearch这样的变量;

- baseurl 是服务器设置中最重要的部分, 只有设置正确, 才能从上面获取软件. 它的格式是:

```shell
baseurl=url://server1/path/to/repository/
　　　　 url://server2/path/to/repository/
　　　　 url://server3/path/to/repository/
```

其中url 支持的协议有 `http://` `ftp://` `file://` 三种. `baseurl` 后可以跟多个url, 你可以自己改为速度比较快的镜像站, 但 **baseurl** 字段只能有一个, 也就是说不能像如下格式:

```shell
baseurl=url://server1/path/to/repository/
baseurl=url://server2/path/to/repository/
baseurl=url://server3/path/to/repository/
```

 以CentOS7基本源为例.

```shell
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.aliyun.com/centos/$releasever/os/$basearch/
        http://mirrors.aliyuncs.com/centos/$releasever/os/$basearch/
failovermethod=priority
gpgcheck=1
exclude=gaim
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
http://mirrors.aliyuncs.com/centos/RPM-GPG-KEY-CentOS-7
```

url 之后可以加上多个选项, 如 `gpgcheck`, `exclude`, `failovermethod`等. 这些选项只对当前所在的 `serverid`有效.

- `exclude`:  排除某些软件在升级名单之外, 可以用通配符, 列表中各个项目要用空格隔开, 这个对于安装了诸如美化包, 中文补丁的朋友特别有用.

- `gpgcheck`: 有1和0两个选择, 分别代表是否是否进行gpg(GNU Private Guard) 校验, 以确定rpm 包的来源是有效和安全的. 这个选项如果设置在[main]部分, 则对每个repository 都有效. 默认值为0.

- `failovermethode` 有两个选项: `roundrobin` 和 `priority`. 意思分别是有多个url可供选择时, yum 选择的次序, roundrobin 是随机选择, 如果连接失败则使用下一个, 依次循环; priority 则根据url 的次序从第一个开始. 如果不指明, 默认是roundrobin.

------

另外, 关于 `$releasever` 与 `$basearch`.

- `$releasever` 为系统版本号, 一般为`5`, `6`, `7`这样. 可以通过`rpm -qi centos-release`命令查看.

- `$basearch`为系统硬件架构(CPU指令集), 一般为`x64_86`, `i386`等. 可以直接通过 `arch`命令查看.

------

有时候与 `baseurl`同级的还有一个 `mirrorlist`, 格式如下

```shell
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
```

按照这个格式, 取$release=7, $arch=x86_64, 访问相应地址, 如[这里](http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os), 得到的是一个纯文本文件, 格式如下.

```shell
http://mirrors.hust.edu.cn/centos/7.2.1511/os/x86_64/
http://mirror.bit.edu.cn/centos/7.2.1511/os/x86_64/
http://mirrors.nwsuaf.edu.cn/centos/7.2.1511/os/x86_64/
http://mirrors.cug.edu.cn/centos/7.2.1511/os/x86_64/
http://ftp.sjtu.edu.cn/centos/7.2.1511/os/x86_64/
http://mirrors.yun-idc.com/centos/7.2.1511/os/x86_64/
http://mirrors.sina.cn/centos/7.2.1511/os/x86_64/
http://centos.ustc.edu.cn/centos/7.2.1511/os/x86_64/
http://mirrors.tuna.tsinghua.edu.cn/centos/7.2.1511/os/x86_64/
http://mirrors.163.com/centos/7.2.1511/os/x86_64/
```

可以看出这是一个镜像列表, 但是不在本地无法编辑. 默认`yum`操作时会依次访问这些地址, 当某一个镜像源访问速度极慢时, 会拖垮整个`yum`操作速度. 所以感觉还是`baseurl`比较好, 可以自由定制.

 **关于epel(Extra Packages for Enterprise) 企业扩展包集**

CentOS官方源中的软件包还是太少了, 官方源及其镜像源中有很多软件包无法找到. epel是社区强烈打造的免费开源发行软件包版本库, 强烈建议安装, 与其他源安装方式相同.

## 3. Ubuntu

参考文章

[关于ubuntu的sources.list总结](http://www.cnblogs.com/jiangz/p/4076811.html?utm_source=tuicool&utm_medium=referral)
[ubuntu添加ppa源(个人软件包集)简单方法](http://www.jbxue.com/LINUXjishu/26993.html)

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

------

## 附录

### 1. 附录1 `yum.conf`文件详解

```shell
[main]
##yum 缓存目录, yum 在此存储下载的 rpm包和数据库, 默认设置为/var/cache/yum
cachedir=/var/cache/yum
##安装完成后是否保留软件包, 0为不保留(默认为0), 1为保留
keepcache=0
##Debug 信息输出等级, 范围为0-10, 默认为2
debuglevel=2
yum 日志文件位置. 可以到/var/log/yum.log 文件去查询过去所做的更新.
logfile=/var/log/yum.log
##包安装策略. 一共有两个选项: newest 和last. 这个作用是如果你设置了多个repository, 而同一软件在不同的repository 中同时存在, yum 应该安装哪一个. 如果是newest, 则yum 会安装最新的那个版本; 如果是last, 则yum 会将服务器id 以字母表排序, 并选择最后的那个服务器上的软件安装. 一般都是选newest.
pkgpolicy=newest
##指定一个软件包, yum 会根据这个包判断你的发行版本, 默认是redhat-release, 也可以是安装的任何针对自己发行版的 rpm包.
distroverpkg=redhat-release
##有1和0两个选项, 表示 yum是否容忍命令行发生与软件包有关的错误. 比如要安装1, 2, 3三个包, 而其中3此前已经安装了, 如果你设为1, 则yum 不会出现错误信息. 默认为0.
tolerant=1
##有1和0两个选项. 设置为1, 则yum 只会安装和系统架构匹配的软件包. 例如, yum 不会将i686的软件包安装在适合i386的系统中. 默认为1.
exactarch=1
##网络连接发生错误后的重试次数, 如果设为0, 则会无限重试. 默认值为6.
retries=6
##这是一个update 的参数, 具体请参阅yum(8), 简单的说就是相当于upgrade, 允许更新陈旧的RPM包.
obsoletes=1
##是否启用插件. 默认1为允许, 0表示不允许. 我们一般会用yum-fastestmirror这个插件.
plugins=1

bugtracker_url=http://bugs.centos.org/set_project.php?project_id=16&ref=http://bugs.centos.org/bug_report_page.php?category=yum
# Note: yum-RHN-plugin doesn't honor this.
metadata_expire=1h
installonly_limit = 5
# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d

##除了上述之外, 还有一些可以添加的选项, 如:

## 排除某些软件在升级名单之外, 可以用通配符, 列表中各个项目要用空格隔开, 这个对于安装了诸如美化包, 中文补丁的朋友特别有用.
exclude=selinux*　　
## 有1和0两个选择, 分别代表是否是否进行gpg(GNU Private Guard) 校验, 以确定rpm 包的来源是有效和安全的. 这个选项如果设置在[main]部分, 则对每个repository 都有效. 默认值为0.
gpgcheck=1　　
```
