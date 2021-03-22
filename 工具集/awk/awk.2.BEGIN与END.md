# Linux-awk命令初级

参考文章

1. [awk 系列：如何使用 awk 的特殊模式 BEGIN 和 END ]((https://linux.cn/article-7654-1.html))
    - 关于BEGIN与END的使用格式: `BEGIN {actions}`, `END {actions}`很清晰, 但是对于ta俩的解释不如参考文章2.
2. [Linux三剑客之awk命令](https://www.cnblogs.com/ginvip/p/6352157.html)
    - 非常详细, 全面的awk文档, 示例清晰.

## 1. 使用方法

awk简单的使用方法如下

```
awk '{/pattern/ action}' filename
```

如果加入`BEGIN`与`END`, 那么可能的脚本如下

```bash
awk '
BEGIN { actions } 
/pattern/ { actions }
/pattern/ { actions }
……….
END { actions } 
' filenames 
```

即`EBGIN`与`END`后也可以跟`actions`. 解释一下

- `BEGIN`: awk 在开始处理输入文件中的文本之前执行的动作.
- `END`: awk 在它正式退出前执行的动作.

> 以下摘自参考文章2
> 
> 通常, 对于每个输入行, `awk`都会执行每个脚本代码块一次. 然而, 在许多编程情况中, 可能需要在`awk`开始处理输入文件中的文本之前执行初始化代码. 对于这种情况, `awk`允许您定义一个`BEGIN`块. 
> 
> 因为 awk 在开始处理输入文件之前会执行`BEGIN`块, 因此它是初始化 FS(字段分隔符)变量、打印页眉或初始化其它在程序中以后会引用的全局变量的极佳位置. 
> 
> awk 还提供了另一个特殊块, 叫作`END`块. awk 在处理了输入文件中的所有行之后执行这个块. 通常, `END`块用于执行最终计算或打印摘要或汇总信息. 

一个简单示例.

`awk.txt`

```
SYN_RECV 798
ESTABLISHED 2444
FIN_WAIT1 2
TIME_WAIT 3982
```

```
$ awk '
BEGIN{print "========== 开始输出 =========="} 
{printf("status: %-10s sum: %d\n", $1, $2)} 
END{print "========== 输出完成 =========="}
' awk.txt

========== 开始输出 ==========
status: SYN_RECV   sum: 798
status: ESTABLISHED sum: 2444
status: FIN_WAIT1  sum: 2
status: TIME_WAIT  sum: 3982
========== 输出完成 ==========
```

我们也来一个简单计算.

```
awk '
BEGIN{a=0}
{a=$2+a}
END{print "最终结果为", a}
' awk.txt
```

`BEGIN`初始化a的值为0, 然后处理每行数据时将第2列的值附加到a变量, 最后由`END`打印.

```
最终结果为 7226
```
