# Shell-获取脚本自身所在目录

参考文章

[Getting the Current/Present working directory of a Bash script from within the script](http://stackoverflow.com/questions/59895/getting-the-current-present-working-directory-of-a-bash-script-from-within-the-s)

[获取shell脚本自身所在目录的Shell脚本分享](http://www.jb51.net/article/59949.htm)

## 1. 情景描述

有一组shell脚本, 它们在同一目录下, 通过相对路径调用. 如下

```
[root@84456460d4fd test]# pwd
/tmp/test
[root@84456460d4fd test]# ls
a.sh  b.sh  c.sh  main.sh
```

`main.sh`的内容如下

```bash
#!/bin/bash
source ./a.sh
source ./b.sh
source ./a.sh
```

如果不是在脚本所在目录下执行, `source`语句可能会报`No such file or directory`的错误.

```
$ pwd
/root
$ bash /tmp/test/main.sh 
/tmp/test/main.sh: line 2: ./a.sh: No such file or directory
/tmp/test/main.sh: line 3: ./b.sh: No such file or directory
/tmp/test/main.sh: line 4: ./a.sh: No such file or directory
```

## 2. 

在`main.sh`中写入`pwd`命令, 然后在`/root`目标下执行, 观察其结果为

```
$ cat /tmp/test/main.sh 
#!/bin/bash
pwd
$ /tmp/test/main.sh 
/root
$ cd /tmp
$ ./test/main.sh 
/tmp
```

可以看到, `pwd`命令得到的**执行脚本**时所在的目录.

再将`pwd`换成使用`dirname $0`试验.

```
$ /tmp/test/main.sh 
/tmp/test
$ ../tmp/test/main.sh 
../tmp/test
$ cd /tmp
$ /tmp/test/main.sh 
/tmp/test
$ ./test/main.sh 
./test
```

看起来像是命令行中使用怎样的路径执行, 就会得到怎样的路径, 这样可能会得到**相对路径**.

使用如下命令可以得到脚本所在的绝对路径...原理就是使用`dirname $0`得到相对路径, `cd`进去, 再使用`pwd`得到绝对路径.

```bash
DIR=$(cd $(dirname $0) && pwd)
echo $DIR
```