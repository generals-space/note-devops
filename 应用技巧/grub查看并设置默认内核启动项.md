# grub查看并设置默认内核启动项

1、查看所有启动项

```log
$ awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2-efi.cfg
0 : openEuler (4.19.90-2112.8.0.0131.oe1.x86_64) 20.03 (LTS-SP3)
1 : openEuler (0-rescue-8117f13c22114ebaa8c1c953d04d64b6) 20.03 (LTS-SP3)
2 : System setup
```

2、修改默认启动项

```
grub2-set-default 2
```

数字2是步骤1中显示的，想设置哪个内核为默认启动项，就填对应内核前面的数字。

3、查看修改结果

```
grub2-editenv list
```

4、重启即可默认进入指定内核。
