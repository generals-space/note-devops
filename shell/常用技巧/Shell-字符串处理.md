# Shell脚本技巧-字符串处理

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

```log
## 两个空格时...
$ str='123 45  6'
## 这样的结果传到bc中会出错的
$ echo "${str// /+}"
123+45++6
```

解决方法是

1. 用两次`echo`命令, `echo`默认会将字符串中出现的空格都缩减成一个.

```log
$ str='123 45   6'
$ echo $str
123 45 6
$ str=`echo $str`
$ echo "${str// /+}" | bc
174
```

2. `sed`匹配多个连续空格

```log
$ echo $str | sed -r 's/( )+/+/g' | bc
174
```

## 无空格分隔分割字符串

原字符串: `12345abcde`

期望结果:

```
1
2
3
4
5
a
b
c
d
e
```

处理方法:

1. `echo 12345abcde | grep -Po '.'`

2. `echo '12345abcde' | fold -w1`

## 4. awk

### 4.1 计算字符串长度

```
$ a='abc 123'
$ echo $a | awk '{print length($0)}'
```
