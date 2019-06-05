# Shell脚本元素-各种括号(一)-中括号

## 2. 中括号(方括号)

### 2.1 单中括号

等同于linux中的`test`命令, 都可用于`if`, `while`语句的条件判断. 

可判断的条件有:

1. 文件系统相关(文件是否存在, 路径是否为目录等)

2. 字符串判断, 只能使用`==`与`!=`(用< , > 比较没有意义)

3. 数值比较, 需要使用相关的`-eq`, `-gt`等操作符.

4. 逻辑判断, `-a`, `-o`标识符

```
$ a=0
$ while [ $a -lt 10 ]; do echo $a; a=`expr $a + 1`; done
0
1
2
3
4
5
6
7
8
9
```

**注意**

1. [, ]左右都需要有空格

2. [ ] 中字符串或者${}变量尽量使用**双引号**扩住，以避免值未定义引用而出错

### 2.2 双中括号

**双中括号比单中括号更加通用的使用方式**.

数值判断, 可以不必使用单中括号的`-eq`, `-lt`等操作符, 直接使用`>`, `<`, `=`, `!=`等符号(貌似`>=`, `<=`不太好使)

逻辑判断, 可以直接使用`&&`, `||`

另外, 字符串比较时, 可以使用通配符和正则表达式两种. 右边的字符串可以是一个模式, 但要注意不能用引号包裹(单双引号都不行).

不过**单中括号的注意点双中括号也需要留心**

```
$ if [[ 1 == 1 ]]; then echo yes; else echo no; fi
yes
$ a='abc'
$ if [[ $a == 'abc' ]]; then echo yes; else echo no; fi
yes
## >=和<=不太好用
$ if [[ 1 >= 1 ]]; then echo yes; else echo no; fi
-bash: syntax error in conditional expression
-bash: syntax error near `1'

## 通配符模式, ?匹配任意单一字符, *匹配任意个任意字符, 右边为模式, 不可以用引号包裹

$ if [[ "hashes" == "hash??" ]]; then echo yes; else echo no; fi
no
$ if [[ "hashes" == hash?? ]]; then echo yes; else echo no; fi
yes
$ if [[ "hashes" == hash* ]]; then echo yes; else echo no; fi
yes

## 正则模式, 要使用`=~`符号

### 这第一行好像有点正则和通配符混用的感觉啊?
$ if [[ "hashes" =~ hash?? ]]; then echo yes; else echo no; fi
yes
$ if [[ "hashes" =~ hash[ed]s ]]; then echo yes; else echo no; fi
yes
$ if [[ "hashes" =~ hash(ed)s ]]; then echo yes; else echo no; fi
no
$ if [[ "hashes" =~ hash(e|d)s ]]; then echo yes; else echo no; fi
yes
$ if [[ "hashes" =~ ^hash(e|d)s ]]; then echo yes; else echo no; fi
yes
```

> 貌似运算符左右两边都要有空格才行

```
$ a='abc'
$ if [[ $a == 'abc' ]]; then echo yes; else echo no; fi
yes
$ if [[ $a == 'ac' ]]; then echo yes; else echo no; fi
no
## 没空格的都会匹配到第一项...
$ if [[ $a=='ac' ]]; then echo yes; else echo no; fi
yes
```