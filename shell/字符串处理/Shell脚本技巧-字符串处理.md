# Shell脚本技巧-字符串处理

## 1. 多行数据合并为单行

主要是`tr`的使用, 它可以完成将一个数据流中的指定字符替换为另一个字符.

```bash
kill $(ps ux | grep crawl | awk '{print $2}' | tr '\n' ' ')
```

## 2. 一行中数字求和

```
$ str='123 45 6'
$ echo "${str// /+}" | bc
174
## 或者用sed
$ echo $str | sed 's/\ /+/g' | bc
174
```

有时数字之间可能不只一个空格, `echo`会出错

```
## 两个空格时...
$ str='123 45  6'
## 这样的结果传到bc中会出错的
$ echo "${str// /+}"
123+45++6
```

解决方法是

1.用两次`echo`命令, `echo`默认会将字符串中出现的空格都缩减成一个.

```
$ str='123 45   6'
$ echo $str
123 45 6
$ str=`echo $str`
$ echo "${str// /+}" | bc
174
```
2.`sed`匹配多个连续空格

```
echo $str | sed -r 's/( )+/+/g' | bc
174
```

## 3. expr命令字符串操作

`expr`有3个子选项可以对字符串操作

- `length string`: 返回字符串string的长度

- `index string string2`: 返回string中包含string2中任意字符第一次出现在位置(从1开始)

- `substr string pos len`: 返回string中从第pos个字符开始, 并且长度是len的字符串。

**求长度**

```
$ a='123abc'
$ expr length $a
6
## 空格也计入长度
$ expr length '123 abc'
7
## 不过变量形式传入的参数不能存在空格
$ a='123 abc'
$ expr length $a
expr: syntax error
```

**索引字符串**

```
$ x='abcdefg12345'
$ y=cd
$ expr index $x $y
3
```

**字符串截取**

```
$ x='abcdefg12345'
$ expr substr $x 2 3
bcd
```

## 4. awk

### 4.1 计算字符串长度

```
$ a='abc 123'
$ echo $a | awk '{print lenght($0)}'
```