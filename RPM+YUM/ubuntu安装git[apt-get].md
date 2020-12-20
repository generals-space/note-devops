# ubuntu安装git[apt-get]

参考文章

1. [Download for Linux and Unix](https://git-scm.com/download/linux)

ubuntu: 18.04 LTS

装了清华大学的镜像源, 但是安装 git 却失败了.

```console
root@b939cfa3b145:/usr/local/git-2.9.5# apt-get install git
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  git-man less libcurl3-gnutls liberror-perl libssl1.0.0 openssh-client
Suggested packages:
  gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-cvs git-mediawiki git-svn keychain libpam-ssh monkeysphere ssh-askpass
The following NEW packages will be installed:
  git git-man less libcurl3-gnutls liberror-perl libssl1.0.0 openssh-client
0 upgraded, 7 newly installed, 0 to remove and 42 not upgraded.
Need to get 6,767 kB of archives.
After this operation, 42.5 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/main amd64 less amd64 487-0.1 [112 kB]
Ign:2 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 libssl1.0.0 amd64 1.0.2n-1ubuntu5.4
Get:3 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 openssh-client amd64 1:7.6p1-4ubuntu0.3 [614 kB]
Ign:4 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 libcurl3-gnutls amd64 7.58.0-2ubuntu3.10
Get:5 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic/main amd64 liberror-perl all 0.17025-1 [22.8 kB]
Get:6 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 git-man all 1:2.17.1-1ubuntu0.7 [804 kB]
Get:7 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 git amd64 1:2.17.1-1ubuntu0.7 [3,915 kB]
Err:2 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 libssl1.0.0 amd64 1.0.2n-1ubuntu5.4
  404  Not Found [IP: 101.6.8.193 443]
Err:4 https://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates/main amd64 libcurl3-gnutls amd64 7.58.0-2ubuntu3.10
  404  Not Found [IP: 101.6.8.193 443]
Fetched 5,467 kB in 2s (2,854 kB/s)
E: Failed to fetch https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.4_amd64.deb  404  Not Found [IP: 101.6.8.193 443]
E: Failed to fetch https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/c/curl/libcurl3-gnutls_7.58.0-2ubuntu3.10_amd64.deb  404  Not Found [IP: 101.6.8.193 443]
E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?
```

去官网找了找, 找到了参考文章1, 给了一个额外的仓库.

```
add-apt-repository ppa:git-core/ppa
apt-get update
apt-get install git
```

> `add-apt-repository`在docker镜像中可能没有, 需要安装`software-properties-common`包.

但是`apt-get install git`的时候实在在慢了...我擦, 还是用源码装吧.

## 源码安装

官网主页找`Tarballs`, 找到最新版(此时为`2.9.5`), 下载解压, 进入到该目录下.

```
cd git-2.9.5
apt-get install zlib1g zlib1g-dev
./configure --prefix=/usr/local/git
make 
```

...没想到竟然出错了

```
GITGUI_VERSION = 0.20.GITGUI
    * new locations or Tcl/Tk interpreter
    GEN git-gui
    INDEX lib/
    * tclsh failed; using unoptimized loading
    MSGFMT    po/bg.msg Makefile:250: recipe for target 'po/bg.msg' failed
make[1]: *** [po/bg.msg] Error 127
Makefile:1663: recipe for target 'all' failed
make: *** [all] Error 2
```

法克, 不过貌似已经生成`git`可执行文件了, 就在这个目录下, 可以执行.

不过通过上面的方法安装的`git`也完成了...气到变形
