# Shell-模板变量替换[eval template 渲染]

参考文章

1. [shell模板变量替换](https://www.cnblogs.com/woshimrf/p/shell-template-variable.html)
    - 评论中提到`envsubst`命令

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

eval "cat <<EOF
$(< test.txt)
EOF
" > result.txt
