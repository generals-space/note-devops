# Shell-各种括号.1.1.小括号.单

参考文章

1. [shell中的括号（小括号, 中括号, 大括号）](http://blog.csdn.net/tttyd/article/details/11742241)
2. [shell中的各种括号](http://blog.csdn.net/weihongrao/article/details/17007575)
3. [linux中双括号和双中括号, 括号和中括号](http://blog.csdn.net/weihongrao/article/details/17006931)
4. [shell脚本中的几个括号总结(小括号/大括号/花括号)](http://blog.csdn.net/lee244868149/article/details/38422437)
5. [shell编程中常用的比较、判断和删除等语法](http://blog.csdn.net/lee244868149/article/details/38424267)
6. [GNU Linux shell中如何进行各进制编码间(二进制、8进制、16进制、base64)的转换](https://blog.csdn.net/yygydjkthh/article/details/50699913)

> 小括号 == (圆括号)

## 1. 命令组

括号中的命令将会新开一个子shell并顺序执行, 所以**括号中可以引用括号外面的变量, 但括号内定义的变量不能够被括号外面的部分使用, 并且括号中对外面变量的修改也不会生效**. 括号中多个命令之间用分号隔开, 最后一个命令可以没有分号, 括号与之后的命令之间也需要有分号, 各命令和括号之间不必有空格. 

```log
## 括号中可以引用括号外面的变量
$ x1='123'
$ (echo $x1)
123

## 括号内定义的变量不能够被括号外面的部分使用
$ (x2='321')
$ echo $x2

## 括号中对外面变量的修改也不会生效
$ x1='123'
$ (x1='abc'; echo $x1); echo $x1
abc
123
```

## 2. 命令替换

等同于反引号`cmd`, shell扫描一遍命令行, 发现了`$(cmd)`结构, 便将`$(cmd)`中的cmd执行一次, 得到其标准输出, **再将此输出放到原来命令行中**. 有些shell不支持, 如tcsh. 

```log
$ xy=$(echo '123')
$ echo $xy
123
```

## 3. 用于初始化数组

```log
$ array=(a b c def)
$ echo ${array[2]}
c
$ echo ${array[3]}
def
```
