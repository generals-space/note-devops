# Ubuntu应用级别问题

## 1. `dpkg`安装 `deb`包无法解决依赖问题

`Ubuntu16.04`下无法通过软件中心安装第三方软件, 只能使用`dpkg -i 你的deb包路径`.

但有时安装到一半由于依赖问题退出, 或是安装完成但由于依赖问题无法启动. 

如果是前者, 失败退出后使用 `sudo apt update && sudo apt -f install`, 然后再次执行`dpkg`命令即可安装成功;

如果是后者, 也是使用`sudo apt update && sudo apt -f install`, 完成后即可正常启动.


## 2. `nautilus` 进程占用内存过高

问题描述: `Ubuntu14.04`下, 每次启动之后没有打开任何进程时 `nautilus`文件管理器就占用99%以上的内存和CPU.

原因分析: 在网上找到的答案让人十分费解, 与 `~/Template`目录有关. 我的确在Template目录中放了两个版本的linux内核源码, 可能是因为文件太多.

解决方法: 将Template下的文件及目录全都移动到其他地方, 问题解决…

## deb包在software center中报错, "wrong architecture i386"

解决方法:

```
sudo dpkg --add-architecture i386 && sudo apt-get update
```

## 附录1. Ubuntu 应用软件列表

主题样式方面:

docky: Mac OS 风格启动器
indicator-multiload: 指示器
variety: 在线壁纸自动切换工具
numix主题
unity-tweak-tool: Unity界面定制工具

chrome, 网易云音乐, vim

axel: 命令行多线程下载工具