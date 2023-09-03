# Shell-模板变量替换[eval template 渲染]

参考文章

1. [shell模板变量替换](https://www.cnblogs.com/woshimrf/p/shell-template-variable.html)
    - 评论中提到`envsubst`命令, 值得一看.

```bash
eval "cat <<EOF
$(< 模板文件路径)
EOF
" > 结果文件路径
```

## 示例

模板文件

```console
$ cat test.txt
a=$a
b=$b
```

测试

```console
$ a=123
$ b=456
$ eval "cat <<EOF
> $(< test.txt)
> EOF
> " > result.txt
$ cat result.txt
a=123
b=456
```

参考文章1中的评论区有人提到`envsubst`命令可以实现同样的效果, 但是很多时候终端使用的不是`bash`, 而是`sh`, 没有这个命令. 而且 docker 中可能没有安装这个命令, 为这样一个功能安装一个命令, 有些不划算. 所以本文中的方法还是很有必要的.

## busybox sh终端

另外, 我在 arm64v8 的 busybox 镜像中测试发现, 由于 busybox 只内置了 sh, `$(< 模板文件路径)`是获取不到模板文件内容的. 如下命令

```sh
a=$(< 模板文件)
```

这样, `$a`将得到空, 没有内容.

为了适应这种情况, 可以将渲染命令改为如下

```bash
eval "cat <<EOF
$(cat 模板文件路径)
EOF
" > 结果文件路径
```

```console
$ a=123
$ b=456
$ eval "cat <<EOF
> $(cat test.txt)
> EOF
> " > result.txt
$ cat result.txt
a=123
b=456
```

## 总结

原理大概是先读取模板文件内容, 得到变量的语句, 然后在使用`eval`执行`cat`命令读入含有变量的语句同时将其渲染.

**`eval "cat 模板文件路径" > 结果文件路径`是无效的.**

要说模拟的话, 可以使用下面的语句.

```bash
while read line 
do
    ## echo $line;
    eval "echo $(echo $line)" >> 结果文件路径
done < 待读取的文件
```

但是`echo`在打印变量的时候会移除 Tab , 空格等字符, 所以这样得到的结果会失去缩进, 所以最终还是要用`cat`
