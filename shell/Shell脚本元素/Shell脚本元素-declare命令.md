# Shell中declare用法

> `declare`或`typeset`内建命令(它们是完全相同的)可以用来限定变量的属性.这是在某些编程语言中使用的定义类型不严格的方式。`declare`是bash版本2之后才有的。`typeset`可以在ksh脚本中运行。

## 1. 语法

```
## 声明变量并设置变量的属性([rix]即为变量的属性）
declare [+/-][属性选项] [变量名称[＝设置值]]
## 显示shell函数内容
declare -f 函数名
## 显示此变量被赋予的属性
declare -p 变量名
```

若不加上任何参数，则会显示全部的shell变量与函数(与执行set指令的效果相同)。

**参数说明：**

- +/- 　"-"可用来指定变量的属性，"+"则是取消变量所设的属性。

- a 数值索引数组, 即普通数组

- A 关联数组, 可看作字典

- i 定义整型变量

- l (lower case)被赋予此选项的变量, 之后被赋值时如果包含大写字母会自动转化为小写

- u (upper case)被赋予此选项的变量, 之后被赋值时如果包含小写字母会自动转化为大写

- r 将变量设置为只读。

- x 指定的变量会成为环境变量，可供shell以外的程序来使用。

- f 仅显示函数。

## 2. 示例

### 2.1 声明整数型变量

```
## 声明整型变量
$ declare -i ab 
## 改变变量内容
$ ab=56 
## 显示变量内容
$ echo $ab 
56
## 如果被赋值为非整型变量, 如字符串, 则其值会变成0
$ ab='abc'
$ echo $ab
0
## 也可以被赋值为字符串形式的整型, 有点像js弱类型
$ ab='12'
$ echo $ab
12
## 查看变量属性
$ declare -p ab
declare -i ab="12"
## 移除变量的i属性
$ declare +i ab
$ ab='abc'
$ echo $ab
abc
## 再次查看变量属性
$ declare -p ab
declare - ab="12"
```

### 2.2 设置变量只读

这大致和C的`const`限定词相同.一个试图改变只读变量值的操作将会引起错误信息而失败.

要注意的是, 这个操作具有不可逆性, 也就是说, 一旦将一个变量声明为`readonly`, 就无法再移除这个属性. 所以**只读类型变量定义时或定义前就需要为其赋值**, 因为之后就再也无法操作了. (除非新开shell)

```
$ declare -r xy
$ echo $xy

$ xy='123'
-su: xy: readonly variable
## 只读属性是无法移除的
$ declare +r xy
-su: declare: xy: readonly variable
## 不如在定义时就指定变量值
$ declare -r yz=123
$ echo $yz
123
```

### 2.3 大小写转换

```
## 自动转换为小写
$ declare -l test
$ test='AbCd'
$ echo $test
abcd
## 自动转换为大写
$ declare -u test
$ test='AbCd'
$ echo $test
ABCD
## 可以包含空格
$ test='AbCd eF'
$ echo $test
ABCD EF
```

### 2.4 定义数组

```
## 声明数组变量
$ declare -a ab=([0]='a' [1]='b' [2]='c')
## 显示变量内容
$ echo ${ab[1]}
b 
## 显示整个数组变量内容
$ echo ${ab[@]} 
a b c
## 可以跳跃声明, 但数组长度只是有值的元素个数
$ declare -a ab='([0]="a" [1]="b" [2]="c")' 
$ echo ${ab[0]}
a
$ declare -a ab=([0]="a" [1]="b" [2]="c")
$ echo ${ab[0]}
a
$ declare -a ab=([0]="a" [1]="b" [3]="c")
$ echo ${ab[2]}

$ echo ${ab[3]}
c
$ echo ${ab[@]}
a b c
## 数组长度是3
$ echo ${#ab[@]}
3
```

### 2.5 定义字典

```
$ declare -A dic
$ dic=([key1]='value1' [key2]='value2' [key3]='value3')

## 打印指定key
$ echo ${dic['key1']}
value1
## 打印所有key值...还是倒序的
$ echo ${!dic[*]}
key3 key2 key1
## 打印所有value...也是倒序的
$ echo ${dic[*]}
value3 value2 value1
## 打印key的个数, 值为空的key也算
$ echo ${#dic[*]}
3
## 添加新的key
$ dic['key4']='value4'
$ echo ${#dic[*]}
4

## 遍历
for key in $(echo ${!dic[*]})
do
    echo "$key : ${dic[$key]}"
done
```