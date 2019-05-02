# Linux应用技巧-DOS和UNIX格式文件相互转换

参考文章

[DOS和UNIX文本文件之间相互转换的方法](http://blog.csdn.net/fan_hai_ping/article/details/8352087)

[Shell中的IFS解惑](http://blog.csdn.net/whuslei/article/details/7187639)

在Vim显示`^M`字符的原因: 在Windows下换行使用`CRLF`两个字符来表示, 其中CR为回车（ASCII=0x0D）, LF为换行（ASCII=0x0A）, 而在Linux下使用LF一个字符来表示. 在Linux下使用vi来查看一些Windows下创建的文本文件时, 有时会发现在每一行尾部有^M字符, 其实它是显示CR回车字符. 

在windows下创建一个空文件, 就输入一个回车然后保存, 传到linxu系统中, 按照如下方式检测.

```
## 这个回车也算是1行
$ wc -l test
1 ./test
## 将文档中的隐式字符转换成8进制
$ cat ./test.sh | od -b
0000000 015 012
0000002
```

可以看到, 第1行(也是唯一一行有两个字符, 正好对应十六进制中的D和A).

在linux下把这个空行删除, 重新键入一个回车, 再次执行上面的操作.

```
$ wc -l test.sh 
1 test.sh
$ cat ./test.sh | od -b
0000000 012
0000001
```

可以看出区别了吧.

下面有一些方法可以处理这种问题（其实这只是Windows和Linux平台表示回车的方法不一样而已!!!!）. 

## 1. 使用dos2unix

一般Linux发行版中都带有这个小工具, 只能把DOS转换为UNIX文件, 命令如下：

```
$ dos2unix dosfile.txt
```

上面的命令会去掉行尾的^M符号. 

## 2. 使用tr

`tr`命令可以拷贝标准输入到标准输出, 替换或者删除掉选择的字符, 只能把DOS转换为UNIX文件, 命令如下：

```
$ tr -d '\r'< dosfile.txt > unixfile.txt
```

## 3. 使用vim


使用vim编辑目标文件, 在命令模式下, 可以使用`:set ff?`查看文件是unix还是dos格式.

DOS转UNIX

```
:set fileformat=unix
```

UNIX转DOS

```
:set fileformat=dos
```

如果你需要把Unix文本文件转换为DOS文本文件, 输入:setfileformat=dos, 你也可以使用ff来替代fileformat, 此时可以输入`:set ff=dos`. 你可以输入:help fileformat来获得跟多的关于选项信息. 

为了能让vim可以自动识别DOS和UNIX文本文件格式, 可以在`~/.vimrc`配置文件中加入如下一行设置

```
setfileformats=dos,unix
```

设置完成后, 使用vim打开DOS文本文件就不会显示^M字符了. 不过治标不治本, 如果是脚本文件, 保留回车符会导致脚本无法执行的. 

```
-bash: ./test.sh: /bin/bash^M: bad interpreter: No such file or directory
```

## 4. 使用Emacs

Emacs是一个Unix下面的文本编辑工具. 它会在底部的状态栏上显示文件的信息. 

DOS转UNIX

```
M-xset-buffer-file-coding-system Unix
```

UNIX转DOS

```
M-xset-buffer-file-coding-system dos
```

## 5. 使用sed

在DOS文件格式中使用CR/LF换行, 在Unix下仅使用LF换行, sed替换命令如下：

```
## DOS转UNIX：
$ sed 's/.$//'dosfile.txt > unixfile.txt
## UNIX转DOS
$ sed 's/$/\r/'unixfile.txt > dosfile.txt
```

## 6. 使用awk

```
## DOS转UNIX
$ awk '{sub("\r$","", $0);print $0}' dosfile.txt > unixfile.txt

## UNIX转DOS
$ awk '{sub("$","\r", $0);print $0}' dosfile.txt > unixfile.txt
```

## 7. 使用Python

```
## DOS转UNIX
$ python -c "importsys; map(sys.stdout.write, (l[:-2] + '\n' for l in sys.stdin.readlines()))"< dosfile.txt > unixfile.txt

## UNIX转DOS
$ python -c "importsys; map(sys.stdout.write, (l[:-1] + '\r\n' for l in sys.stdin.readlines()))"< dosfile.txt > unixfile.txt
```

## 8. 总结
         
还有其它DOS和UNIX文本文件的转换方法, 个人推荐使用vim命令. 但是, 对于大型的文件, 推荐使用perl工具, 你也不会希望在vim或Emacs中打开几个G的文本文件. 