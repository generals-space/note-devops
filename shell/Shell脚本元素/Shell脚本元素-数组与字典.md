# Shell脚本元素-数组与字典

参考文章

[玩转Bash变量](https://segmentfault.com/a/1190000002539169)

## 1. 数组

原文链接

[Shell数组：shell数组的定义、数组长度](http://c.biancheng.net/cpp/view/7002.html)

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。类似与C语言，数组元素的下标由0开始编号。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于0。

### 1.1 定义数组

在Shell中，用括号来表示数组，数组元素用“空格”符号分割开。定义数组的一般形式为：`array_name=(value1 ...valuen)`. 索引从0开始计数.

例如：

```
array_name=(value0 value1 value2 value3)
```

或者

```
array_name=(
value0
value1
value2
value3
)
```

**注意没有逗号或分号**

还可以单独定义数组的各个分量：

```
array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
```

**可以不使用连续的下标，而且下标的范围没有限制**。

### 1.2 读取数组

读取数组元素值的一般格式是：`${array_name[index]}`

例如：

```
valuen=${array_name[2]}
```

举个例子：

```
#!/bin/sh
NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Index: ${NAME[0]}"
echo "Second Index: ${NAME[1]}"
```

运行脚本，输出：

```
$./test.sh
First Index: Zara
Second Index: Qadir
```

使用`@`或`*`可以获取数组中的所有元素，例如：

```
${array_name[*]}
${array_name[@]}
```

举个例子：

```
#!/bin/sh
NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Method: ${NAME[*]}"
echo "Second Method: ${NAME[@]}"
```

运行脚本，输出：

```
$./test.sh
First Method: Zara Qadir Mahnaz Ayan Daisy
Second Method: Zara Qadir Mahnaz Ayan Daisy
```

**获取数组的长度**

获取数组长度的方法与获取字符串长度的方法相同，例如：

```
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```

### 1.3 扩展

使用索引直接定义数组时, 可以跳跃定义

```
## 不定义array[1]的值
array[0]=value0
array[2]=value2
```

这种情况下, **数组的长度是实际有数据的元素个数而不是索引范围**. 这一点与高级编程语言不同.

## 2. 字典

必须通过`declare`先声明, 没有办法像数组那样直接通过变量名定义.

### 2.1 定义和取值

```
#必须先声明
$ declare -A dic
$ dic=([key1]='value1' [key2]='value2' [key3]='value3')

## 打印指定key
$ echo ${dic['key1']}
value1
## 添加新的键
$ dic['key4']='value4'
$ echo ${#dic[*]}
4
```

------

正确

```
$ declare -A dic
$ dic=(
> [key1]='val1'
> [key2]='val2'
> )
$ echo ${dic['key1']}
val1
```

错误, 不使用`declare`声明的定义不会提示错误, 但取值都是空的.

```
$ abc=(
[key1]='val1'
[key2]='val2'
)
$ echo ${abc[key2]}

$ echo ${abc['key2']}
```

也可以先声明多个, 再依次定义

```
$ declare -A dic1 dic2
$ dic1=([key1]='val1' [key2]='val2')
$ dic2=([key1]='value1' [key2]='value2')
$ echo ${dic1['key2']}
val2
$ echo ${dic2['key2']}
value2
```

### 2.2 长度, 索引(遍历)

`${dic[*]}`: 得到所有的值, `${dic[@]}`可以达到同样的效果.

`${!dic[*]}`: 得到所有的键, `${!dic[@]}`可以达到同样的效果.

`${#dic[*]}`: 获取字典长度, `${#dic[@]}`可以达到同样的效果.

```
$ declare -A dic
$ dic=([key1]='value1' [key2]='value2' [key3]='value3')
## 遍历
for key in $(echo ${!dic[*]})
do
    echo "$key : ${dic[$key]}"
done
## 打印所有键...还是倒序的
$ echo ${!dic[*]}
key3 key2 key1
## 打印所有值...也是倒序的
$ echo ${dic[*]}
value3 value2 value1
## 打印key的个数, 值为空的键也算!!!
$ echo ${#dic[*]}
3
```

### 2.3 切片

数组与字典都有这个用法, 毕竟本质上两者都是数组, 后者叫作`关联数组`.

`${dic[*]:M:N}`: 切片, N是offset, 从0开始, M是length. `${dic[@]:M:N}`可以达到同样的效果.

延用上面的示例

```
$ echo ${dic[*]:0:2}
value3 value2
```

> 注意: 只能返回值的切片, 无法得到键的切片. 另外, 得到的值都是倒序的.