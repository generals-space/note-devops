# Centos7使用YUM进行install或update出现KeyboardInterrupt错误

参考文章

1. [Centos7使用YUM进行install或update出现KeyboardInterrupt错误](http://www.merlinchinta.com/201604/21659.html)

2. [Centos7使用YUM进行install或update出现KeyboardInterrupt错误](https://www.aliyun.com/jiaocheng/467768.html)

在`首都在线`的云服务器上执行`yum update -y`, 结果4台中有2台出现如下错误(另外两台正常)

```
File "/usr/lib/python2.7/site-packages/urlgrabber/grabber.py", line 1517, in _do_perform
    raise KeyboardInterrupt
```

`KeyboardInterrupt`...就中断了, 很是奇怪, 而且由于出错机率是50%, 也不能认为是因为python版本的问题(都是2.7, 虽然不知道如何做到让yum能运行在python2.7上的).

不过参考文章1, 2给出的解决方案还是蛮靠谱的.

1. 打开文件:

`/usr/lib/python2.7/site-packages/urlgrabber/grabber.py`

2.在文件的1510行左右找到下面这句代码:

```py
elif errcode in (42, 55, 56):
```

修改为:

```py
elif errcode == 42:
```

完成后再次执行`yum`就正常了.