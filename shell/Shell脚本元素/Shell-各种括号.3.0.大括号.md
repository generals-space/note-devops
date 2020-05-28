# Shell-各种括号.3.0.大括号

参考文章

1. [玩转Bash变量](https://segmentfault.com/a/1190000002539169)
2. [菜鸟学Linux - 变量基本规则](https://www.cnblogs.com/jonathanlin/p/4063205.html)
    - 逻辑匹配/替换表格
3. [shell的字符串截取](https://my.oschina.net/u/3314358/blog/2051268)
    - 字符串切片: 固定位置截取(正向与反向)
4. [Bash Shell字符串操作小结](https://my.oschina.net/aiguozhe/blog/41557)
    - 字符串切片: 反向截取示例 `${str:(-4):3}`

大括号只有单层的, 没有`{{expression}}`的用法.

## 1. 序列化字符串生成

1. 两个点号`.`生成顺序字符串
2. 逗号`,`分隔, 不可以有空格

```bash
touch test{1..4}.txt
ls                      ## test1.txt  test2.txt  test3.txt  test4.txt
```

```bash
touch {test{1..4},testab}.txt
ls                      ## test1.txt  test2.txt  test3.txt  test4.txt  testab.txt
```

## 2. 代码块(匿名函数)

代码块, 又被称为内部组, 这个结构事实上创建了一个匿名函数. 

与小括号中的命令不同, 大括号内的命令不会新开一个子shell运行, 即脚本余下部分仍可使用括号内变量. 

括号内的命令间用分号隔开, **最后一个也必须有分号**. **{}中的第一个命令和左括号之间必须要有一个空格**. 

```bash
{ a=1; ((a++));}; echo $a; ## 2
```

## 3. 大小写转换

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

## 5. 切片实现: 固定位置截取

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

## 6. 查找替换

就是精确匹配后替换啦.

- `${var/str/newstr}`: 变量`var`包含`str`字符串, 则只有第一个`str`会被替换成`newstr`;
- `${var//str/newstr}`: 变量`var`包含`str`字符串, 则全部的`str`都会被替换成`newstr`;

```bash
var='hello world'
echo ${var/o/i}     ## helli world
echo ${var//o/i}    ## helli wirld
```

同样, 这两种方法也不会修改原变量`var`的值, 并且也可以使用通配符, 不过只能使用`?`与`*`.

```bash
var='hello world'
echo ${var/?o/ii}       ## helii world
echo ${var//?o/ii}      ## helii iirld
```
