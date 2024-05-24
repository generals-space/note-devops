# Ubuntu镜像源修改

参考文章

1. [Ubuntu修改镜像源的两种方法](https://www.jianshu.com/p/e08910410796)

看了看, 清华大学, ~~网易~~与阿里关于 ubuntu 的镜像源的使用方法都讲解得很明白.

ubuntu 的镜像源版本目录不是按版本号而是按版本名来的(真tm xxx), 可以使用`cat /etc/os-release`, `cat /etc/issue`, 或是`uname -a`查看.

我在 docker 里可以通过`os-release`查看.

```log
$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.1 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.1 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

如上, 版本号为20.04, 代号为 focal.
