# Shell脚本元素-EOF标记

参考文章

[cat和EOF的使用](http://luxiaok.blog.51cto.com/2177896/711822)

[怎么在 shell 中用cat>test1<<EOF写入文件时不输出EOF的变量？](https://www.v2ex.com/t/125834)

[cat<<EOF与cat <<-EOF的区别](http://blog.csdn.net/apache0554/article/details/45508631)

EOF: End Of File, 表示文本结束符.

## 1. 初级使用方法

`EOF`最基本的使用方法就是输出多行字符串到文件. 如下

```bash
#!/bin/bash
cat > eof.txt << EOF
第1行
第2行
第3行
EOF
```

上面的命令会生成`eof.txt`文件, 其内容就是列出的3行文字. 这种使用方法在比如脚本中内嵌一段比较长的自定义的配置, 需要输出到指定配置文件时极其有用. 当然, `>`与`>>`重定向符都是可以使用的.

虽然可以使用`echo -e "第1行\n第2行\n第3行\n" > eof.txt`达到同样的效果, 但是可读性很差, 也极易出错.

> PS: `echo`的`-e`选项将会对其后字符串中的反斜线`\`转义, 不只是`\n`换行符, 还有`\t`制表符等. `-e`选项的出现不因后面的字符串是单引号还是双引号而有所区别.

```bash
## 单引号换行
$ echo -e '1\n2\n3'
1
2
3
## 双引号换行
$ echo -e "1\n2\n3"
1
2
3
```

不过使用双引号时`$`变量引用依然有效, 单引号就不行了.

------

~~在命令行中, 第2个`EOF`符并不是通过EOF字符串表示的, 而是`Ctrl+D`~~. 扯, 我自己试验的时候EOF字符串有效, 而`Ctrl+D`报错. 

```txt
$ cat > test << EOF
> 1
> 2
> 3
> EOF
$ cat test 
1
2
3
$ cat > test << EOF
> 1
> 2
> 3
> -bash: warning: here-document at line 37 delimited by end-of-file (wanted `EOF')
```

## 2. 进阶使用方法

### 2.1 内嵌变量

待输出的多行文本中可以包含变量(和命令), 在**输出到文件之前**就会被解析. 比如

```bash
#!/bin/bash

line_num=3
cat > test.txt << EOF
第1行
第2行
第$line_num行
当前路径在$(pwd)
EOF
```

生成的`test.txt`文件内容为

```ini
第1行
第2行
第3行
当前路径在/tmp
```

表面看来倒是很和谐美好, 但如果包含的变量并不是对当前shell脚本而言的呢? 比如

```bash
#!/bin/bash

cat >> /etc/profile << EOF
export JAVA_HOME=/usr/local
export PATH=$JAVA_HOME/bin:$PATH
EOF
```

上述脚本输出到`/etc/profile`的内容是

```bash
export JAVA_HOME=/usr/local
export PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
```

看到了?

第2个`export`的语句将`$JAVA_HOME`与`$PATH`的值都预先解析了出来, 然而原脚本中并没有`JAVA_HOME`的定义, 所以它的值为空.

------

现在我们的目的是追加`$JAVA_HOME`与`$PATH`字符串到`/etc/profile`, 方法有两个:

1. 带`$`符的变量前加反斜线`\`转义

2. 第一个EOF带单引号, 即`'EOF'`

#### 2.1.1 特定变量转义

```bash
#!/bin/bash

cat >> /etc/profile << EOF
export JAVA_HOME=/usr/local
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
```

其在`/etc/profile`中的输出为

```bash
export JAVA_HOME=/usr/local
export PATH=$JAVA_HOME/bin:$PATH
```

#### 2.1.2 带单引号的EOF

```bash
#!/bin/bash

cat >> /etc/profile << 'EOF'
export JAVA_HOME=/usr/local
export PATH=$JAVA_HOME/bin:$PATH
EOF
```

其在`/etc/profile`中的输出为

```bash
export JAVA_HOME=/usr/local
export PATH=$JAVA_HOME/bin:$PATH
```

在这个例子中, 两种方法的结果相同.

不过, 前者中还可以自由地引用脚本中定义的变量, 需要直接输出字符串时添加`\`即可, 不过如果变量多了, 书写可能会比较麻烦; 而后者中, 输出的所有内容都是纯粹的字符串, 不会被解析.

### 2.2 '-EOF'的用法

使用`EOF`的一个隐含规则是, 第2个EOF标记需要在行首, 前面不可以有空格或Tab键. 如果有空格, 脚本执行会报错.

```txt
$ cat eof_test.sh
#!/bin/bash
line_num=3
cat > test.txt << EOF
第1行
第2行
第$line_num行
当前路径在$(pwd)
    EOF
$ ./eof_test.sh
eof_test.sh: line 8: warning: here-document at line 3 delimited by end-of-file (wanted `EOF')
```

有一种hack的做法是, 使用`<<- EOF`. `<<-`之间没有空格, 而`-`与`EOF`之间无所谓. 不过, 第2个EOF前只能是Tab键, 如果是空格还是会报错的. 如下

```bash
$ cat eof_test.sh
#!/bin/bash
line_num=3
cat > test.txt <<- EOF
第1行
第2行
第$line_num行
当前路径在$(pwd)
    EOF
$ ./eof_test.sh
$ cat test.txt
第1行
第2行
第3行
当前路径在/tmp
```

根据参考文章中的说明: **如果重定向的操作符是`<<-`, 那么分界符`EOF`所在行的开头部分的制表符`Tab`都将被去除.**

------

...这个技巧好像纯粹用来炫技的, 完全没有实际作用啊.

如果说, 让代码更加优雅也算作用的话, 还是有一点的. 比如, 默认的`<< EOF`的重定向, 多行文本中每行字符前的空格与Tab都是会表现出来的. 下面脚本中多行文本的第3行以4个空格开关, 第4行以一个Tab键开头.

```bash
$ cat eof_test.sh
#!/bin/bash
line_num=3
cat > test.txt << EOF
    第1行
    第2行
    第$line_num行
	当前路径在$(pwd)
EOF

$ ./eof_test.sh
$ cat test.txt
    第1行
    第2行
    第3行
	当前路径在/tmp
```

这些内容输出到文件时都带有了缩进. 不过这有可能不是我们想要的, 想想在`if..fi`块内使用, 希望使用缩进, 那这些脚本中的缩进都会表现在输出文件中, 很难将脚本写得拥有优雅的缩进同时又能不影响输出文件的. 

下面的脚本中`cat ... << EOF`的多行文本前两行没有空格, 第3行是4个空格, 第4行是一个Tab. 可以想象, 如果在脚本中保持缩进, 输出到文件的内容会是什么鬼样子.

```bash
$ cat eof_test.sh
#!/bin/bash
line_num=3
if [ $line_num -eq 3 ]; then
    cat > test.txt << EOF
第1行
第2行
    第$line_num行
	当前路径在$(pwd)
EOF
fi
$ ./eof_test.sh
第1行
第2行
    第3行
	当前路径在/tmp
```

使用`<<- EOF`, 可以忽略直到第2个`EOF`标记前的Tab制表符. 缩进可以用空格. 如下, `cat ... <<- EOF`与`EOF`前使用Tab缩进, 输出的多行文本第3行都以两个Tab缩进, 这些在输出文本中并没有被体现, 多行文本的第4行, 先用两个Tab, 再加4个空格, 可以的输出文本中得到正常的缩进. 

```bash
$ cat eof_test.sh
#!/bin/bash
line_num=3
if [ $line_num -eq 3 ]; then
        cat > test.txt <<- EOF
                第1行
                第2行
                第$line_num行
                    当前路径在$(pwd)
        EOF
fi
$ ./eof_test.sh
第1行
第2行
第3行
    当前路径在/tmp
```

这样的脚本是不是漂亮了很多?

...是不是很作死?

## 3. `su`切换身份执行多条命令.

除了cat, 应该还有很多命令可以使用`EOF`标记, 经验使然, 还没有那么多积累, `su`也算其中之一. 具体脚本内使用`su`切换身份执行命令在另一篇文章有详细介绍, 并且有一些问题也用到了本文提到的解决方法.