# Kali系统定制

## 1. 静态IP

新建`/etc/network/interfaces.d/eth0`文件, 内容如下

```
auto eth0
iface eth0 inet static
address 172.32.100.40
netmask 255.255.255.0
gateway 172.32.100.2
```

然后重启网络服务即可

```
$ service networking restart
```

`interfaces`文件中还有很多其他的设置项，如需要了解更多的信息，可以使用`man 5 interfaces`查询.

## 2. 源

修改`/etc/apt/sources.list`文件, 注意将原官方源的行注释掉.

kali1.0

```
deb http://mirrors.aliyun.com/kali kali main non-free contrib
deb-src http://mirrors.aliyun.com/kali kali main non-free contrib
deb http://mirrors.aliyun.com/kali-security kali/updates main contrib non-free
```

kali2.0

```
#kali官方源
deb http://http.kali.org/kali kali-rolling main non-free contrib
#中科大的源
deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
```

然后

```
apt-get update & apt-get upgrade
apt-get dist-upgrade
apt-get clean
```

## 3. 输入法fcitx

```
apt-get install fcitx fcitx-table-wbpy fcitx-googlepinyin
```

## 4. kali2.0声卡无声音

[kali2.0声卡无声音和安装中文输入法](http://www.cnblogs.com/Bgod/p/6031635.html)

升级到Kali2.0后无声音, 系统设置中看不到输出设备(但是系统未升级时是可以播放声音的). 其实并不是不支持声卡驱动了, 只是root用户下默认关闭.

编辑`/etc/default/pulseaudio`

```
#root下是默认关闭声卡驱动的， 开机自动开启
PULSEAUDIO_SYSTEM_START=1 
DISALLOW_MODULE_LOADING=0
```

重启即可.