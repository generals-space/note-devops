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
