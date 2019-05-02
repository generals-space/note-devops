# Fedora初始化

适用环境: fedora24

## 1. 主题方面

无法原生安装`docky`启动器, 不过可以从命令行安装 `numix`主题, 再安装 `gnome-tweak-tool`启用.

另外, Gnome3 隐藏标题栏, 去除最大化标题栏

```shell
sudo gedit /usr/share/themes/当前主题/metacity-1/metacity-theme-3.xml
```

```xml
<frame_geometry name="max" has_title="false" title_scale="medium" parent="normal" rounded_top_left="false" rounded_top_right="false">
　　<distance name="left_width" value="0" />
　　<distance name="right_width" value="0" />
　　<distance name="left_titlebar_edge" value="0"/>
　　<distance name="right_titlebar_edge" value="0"/>
    <!--
　　This needs to be 1 less then the
　　title_vertical_pad on normal state
　　or you'll have bigger buttons -->
　　<distance name="title_vertical_pad" value="0"/>
　　<border name="title_border" left="10" right="10" top="0" bottom="0"/>
　　<border name="button_border" left="0" right="0" top="0" bottom="0"/>
　　<distance name="bottom_height" value="0" />
</frame_geometry>
```

有时候上面的方法可能不起作用, 可以安装一个叫做`Pixel Saver`的gnome-shell扩展. 网址在[这里](https://extensions.gnome.org/extension/723/pixel-saver/)

## 2. gnome-shell

1. [System Monitor](https://extensions.gnome.org/extension/1064/system-monitor/)

## 3. 输入法

安装 `fcitx`系输入法, 并安装`im-chooser`工具

```shell
dnf install fcitx fcitx-pinyin fcitx-configtool  ##注意`fcitx-configtool`一定要安装
dnf install im-chooser
```

首先执行`im-chooser` 将默认输入法由`iBus`更换为`fcitx`, 然后执行`fcitx-configtool`进行设置.

话说, fedora下的fcitx没有五笔, 不过可以安装`fcitx-cloudpinyin`, 作为拼音输入法的插件. 感觉还不错. 貌似不需要重启或注销.

chrome
http://blog.csdn.net/zgzhjj001/article/details/25342215
libnss3.so(NSS_3.19.1)(64bit) is needed by google-chrome-stable

教你如何在Fedora,CentOS,RHEL中检查RPM包的依赖性
http://os.51cto.com/art/201408/448600.htm

## 4. 媒体播放器

参考文章

[Fedora 22 用户如何安装 VLC media player](http://www.linuxidc.com/Linux/2015-06/118401.htm)

fedora22 自带的视频播放器不能播放.mp4格式的文件. 建议下载`vlc`播放器. `vlc`不再默认源中, 需要导入`rpmfusion`源.

```shell
rpm -ivh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-22.noarch.rpm
dnf install vlc
```
