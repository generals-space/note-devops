# Linux-awk命令初级

awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在对数据分析并生成报告时，显得尤为强大。简单来说就是awk把文件逐行读入，以空格为默认分隔符将每行切片，再将切开的部分进行各种分析处理。

## 1. 使用方法

```
awk '{pattern+action}' filename
```

其中`pattern`表示awk在数据中查找的内容，而`action`是在找到匹配内容时所执行的一系列命令。

`pattern`是要表示的正则表达式，用斜杠括起来。

大括号'{}'不需要在程序中始终出现，但它们用于根据特定的模式对一系列指令进行分组。**大括号只能用单引号包裹, 双引号会不生效**

awk语言最基本的功能是在文件或者字符串中基于指定规则浏览和提取信息，awk提取信息后才能进行其他文本操作。完整的awk脚本通常用来格式化文本文件中的信息。

## 2. 入门实例

### 2.1  `awk '{action}'`

假设`last -n 5`的输出如下(显示最近登录的5个帐号信息)

```
[root@www ~]# last -n 5 <==仅取出前五行
root     pts/1   192.168.1.100  Tue Feb 10 11:21   still logged in
root     pts/1   192.168.1.100  Tue Feb 10 00:46 - 02:28  (01:41)
root     pts/1   192.168.1.100  Mon Feb  9 11:41 - 18:30  (06:48)
dmtsai   pts/1   192.168.1.100  Mon Feb  9 11:41 - 11:41  (00:00)
root     tty1                   Fri Sep  5 14:09 - 14:10  (00:01)
```

若只是想显示最近登录的帐号名称(即只显示第一列)

```
#last -n 5 | awk  '{print $1}'
root
root
root
dmtsai
root
```

本例中awk的工作流程为：读入由'\n'换行符分割的一条记录，然后将记录按指定的分隔符(默认为空格或tab制表符)划分列。`$0`表示所有列，`$1`表示第一列，以此类推。所以$1表示第一列，即为登录用户。

这是awk+action的示例，每行都会执行`action{print $1} `

### 2.2 `awk '{pattern}'`

搜索`/etc/passwd`中有root关键字的所有行

```
#awk -F: '/root/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

这是`pattern`的使用示例，匹配了`pattern`(这里是root)的行才会执行action(此处未指定action，默认输出每行的内容)。

pattern支持正则。

### 2.3 `awk '{pattern+action}'`

搜索`/etc/passwd`有root关键字的所有行，并显示对应的shell(第7列)

```
# awk -F: '/root/{print $7}' /etc/passwd             
/bin/bash
```

此处指定了`action{print $7}`