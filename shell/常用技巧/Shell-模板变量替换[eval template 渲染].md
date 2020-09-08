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

> 按行读取文件时可能会用到, `while read line do echo $line; done < 待读取的文件`.

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

> 参考文章1中的评论区有人提到`envsubst`命令可以实现同样的效果, 但是很多时候终端使用的不是`bash`, 而是`sh`, 没有这个命令, 那么文中的方法还是很有必要的.

------

另外, 我在 arm64v8 的 busybox 镜像中测试发现, 由于 busybox 只内置了 sh, `$(< 模板文件路径)`是获取不到值的. 如下命令

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
