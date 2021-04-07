# ssh远程执行命令.2.-n参数, 去除本地标准输入的干扰

参考文章

1. [ssh命令输入问题（-n选项作用）](http://blog.csdn.net/notsea/article/details/42028359)

在一个shell脚本里嵌入ssh远程执行命令的代码时, 有可能会截取到脚本中传入的标准输入, 对其他操作造成影响.

## 示例

来看一个例子, 假设`test.sh`文件内容如下

```bash
#!/bin/bash
while read line  
do  
  echo $line  
  ssh root@192.168.1.1 'date'
done << EOF  
1  
2  
3  
4  
5  
EOF
```

我们希望这个脚本每输出一个数字, 就远程执行一次`date`命令, 所以理论上应该有10行输出. 但实际执行时输出如下, 只有两行.

```console
$ ./test.sh
1
Fri Sep  9 11:26:18 CST 2016
```

也就是说, while循环只读到1, 就认为到了文件末尾了, 那剩下的几行被谁读取了? 我们猜测是`ssh`, while所需要的标准输入流被传到ssh要执行的命令中去了.

我们验证一下, 将`test.sh`修改成如下

```bash
#!/bin/bash
while read line  
do  
  echo $line  
  ## ssh root@192.168.1.1 'date'
  ssh root@192.168.1.1 'read a; echo $a; read b; echo $b; read c; echo $c; read d; echo $d; date'
done << EOF  
1  
2  
3  
4  
5  
EOF
```

然后再次执行`test.sh`

```console
$ ./test.sh
1
2
3
4
5
Fri Sep  9 11:33:51 CST 2016
```

呐, 我们看到`while`循环读取的标准输入流全都被`ssh`get到了. 这并不是我们所希望的, 想一想, 如果我们想通过while循环读取IP列表, 结果剩下的列表都被第一行的ssh截获了...

## 重现

我们尝试一下. 新建一个IP列表文件`ip_list`, `test.sh`从其中读取IP信息并远程执行`date`命令.

假设存在`ip_list`, `test.sh`两个文件, 内容分别如下

```
192.168.1.1
192.168.1.2
192.168.1.3
192.168.1.4
```

```bash
#!/bin/bash
while read IP
do
  echo $IP
  ssh root@$IP 'date'
done < ./ip_list
```

执行它

```console
$ ./test.sh
192.168.1.1
Fri Sep  9 11:33:31 CST 2016
```

结果不出所料...

## 解决方法

ssh提供的`-n`选项, 专门解决这个问题. 它是将`/dev/null`作为ssh执行命令时的标准输入, 从而屏蔽本地输入.

我们将`test.sh`中ssh命令加上`-n`选项

```
ssh -n root@$IP 'date'
```

再次执行

```console
$ ./test.sh
192.168.1.1
Fri Sep  9 11:33:46 CST 2016
192.168.1.2
Fri Sep  9 11:53:33 CST 2016
192.168.1.3
Fri Sep  9 11:33:46 CST 2016
192.168.1.4
Fri Sep  9 11:41:56 CST 2016
```

成功.
