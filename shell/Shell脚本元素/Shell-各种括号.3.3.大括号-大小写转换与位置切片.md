# Shell-各种括号.3.3.大括号-大小写转换与位置切片

## 1. 大小写转换

```bash
HI=HellO

echo "$HI"        ## HellO
echo ${HI^}       ## HellO
echo ${HI^^}      ## HELLO
echo ${HI,}       ## hellO
echo ${HI,,}      ## hello
echo ${HI~}       ## hellO
echo ${HI~~}      ## hELLo
```

`^`大写, `,`小写, `~`大小写切换. 重复一次只修改首字母, 重复两次则应用于所有字母. 

混着用会怎样？

```bash
echo ${HI^,^}   ## HellO
```

看来是不行的×_×

## 2. 切片实现: 固定位置截取

`${varible:start:len}`

截取变量`varible`从位置`start`开始长度为`len`的子串, 第一个字符的位置起始为0.

```bash
var=testcase
echo ${var:0:4} ## test
echo ${var:4:4} ## case
echo ${var:4} ## case 截取到末尾
```

```bash
var=testcase
echo ${var:-4:4}    ## testcase
echo ${var:(-4):4}  ## case
echo ${var:0-4:4}   ## case
```

**注意点**

1. 反向截取时`start`格式为`0-n`, `0-`不可省略, 直接写一个负值, 操作无效.
2. `start`可以小于0, 但没有任何作用, 不能实现倒数截取的功能. 当`start<0`时, 截取功能无效, `len`无论取何值都会输出整个字符串.
    - `echo ${var:-1:4}` 输出 `testcase`
    - `echo ${var:-1:-4}` 输出 `testcase`
3. `start<0`时, `len`可取负值(虽然没什么用), 但是`start>=0`时, `len`只能>=0, 否则会报错.
    - `echo ${var:0:-1}` 报错 `-bash: -1: substring expression < 0`
