# Linux-ClamAV

[官方网站](http://www.clamav.net/)

## 1. 安装clamav杀毒软件并扫描

```
$ yum install clamav -y
$ clamscan -r --bell -i 扫描的目录 -l 扫描结果存放文件
```

> 安装完成后会创建`clam`用户.

全系统扫描比较耗时，建议先扫描`/usr`, `/bin`, `/etc/rc.d`, `/tmp`

`--remove`参数可以直接删除病毒文件.

## 2. 更新

常规更新软件包

```
$ yum update clamav
```

然后要更新`clamav`的病毒库. 这要用到clamav的`freshclam`命令, 直接执行即可.

```
$ freshclam 
ClamAV update process started at Tue Feb  6 10:09:30 2018
WARNING: Your ClamAV installation is OUTDATED!
WARNING: Local version: 0.99.2 Recommended version: 0.99.3
DON'T PANIC! Read http://www.clamav.net/documents/upgrading-clamav
Downloading main-58.cdiff [  1%]
...
Downloading bytecode-318.cdiff [100%]
bytecode.cld updated (version: 319, sigs: 75, f-level: 63, builder: neo)
[LibClamAV] Detected duplicate databases /var/lib/clamav/daily.cld and /var/lib/clamav/daily.cvd. The /var/lib/clamav/daily.cld database is older and will not be loaded, you should manually remove it from the database directory.
Database updated (6412033 signatures) from db.cn.clamav.net (IP: 124.35.85.83)
```