# ubuntu美化

适用ubuntu版本:14.04, 15.04+未测试

## 1. 安装Numix主题

[参考文章](http://os.51cto.com/art/201406/442093.htm)

### 1.1 安装Unity-Tweak-Tool

ubuntu默认的unity桌面使用`unity-tweak-tool`进行设置最为方便. 如果是`gnome`桌面环境下, 则安装`gnome-tweak-tool`更好一些.

```shell
sudo apt-get install unity-tweak-tool
```

### 1.2 安装Nunix主题与图标

```shell
sudo add-apt-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install numix-gtk-theme numix-icon-theme-circle
```
### 1.3 在unity-tweak-tool中设置

从命令行或dash中启动`unity-tweak-tool`, 在`Appearance`栏中设置`theme`, `icon`选项分别启用`numix`与`numinx-circle`. 若未能即时生效, 可以尝试退出并重新登陆.

> ps:

> 在Numix主题安装完成并生效后, 重新启动发现Numix主题不见了, 在`unity-tweak-tool`显示当前的确为Numix主题. 原因可能是`unity-tweak-tool`不是以root身份设置, 在命令行重新用`sudo unity-tweak-tool`重新设置一次就好(原来是直接在dash中打开的).

> 嗯, 上面的做法好像不对. 后来再次尝试的时候不管怎样都不会更改主题了. 有一条命令`compiz --replace`, 可以使用numix主题立刻生效. 不过好像需要手动加入到`startup`或`.bashrc`启动命令.

## 2. Variety壁纸自动切换工具

[参考文章](http://www.educity.cn/linux/1575767.html)

Variety是一个切换壁纸的应用, 并可以定期的使用用户指定的或者从网上下载的图像进行切换, 图片可以包含多种在线资源等.

该版本支持gnome, xfce, kde等桌面环境, 而且运行起来更加流畅. 支持特效设置立即生效, 以及可定制的通知区域图标等.

```shell
sudo add-apt-repository ppa:peterlevi/ppa
sudo apt-get update
sudo apt-get install variety
```

通过dash或bash都可以使用`variety`启动它.

## 3. 安装一些指示器程序

有很多第三方的指示器程序, 通过这些程序你可以监视你的桌面信息, 例如天气、系统性能等. `indicator-nultiload`可以监测系统性能的小工具, 默认出现在顶栏, 可设置显示CPU, 内存, 网络, Swap交换区与硬盘等实时情况.

```shell
sudo apt-get install indicator-multiload
```

另外有conky工具功能更加强大, 但配置也更为复杂, 而且一般天气跟磁盘分区等信息使用频率不大, 没有必要去花时间.

## 4. docky启动器

类似于Mac的软件启动器, 比ubuntu自带的好一点