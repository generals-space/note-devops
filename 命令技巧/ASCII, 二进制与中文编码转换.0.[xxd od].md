# ASCII, 二进制与中文编码转换[xxd od]

参考文章

1. [在bash中，我怎样才能从二进制转换为utf8？](https://cloud.tencent.com/developer/ask/138070)
    - `sed -E 's/.*:(( [01]+){0,6}).*/\1/'`: 截取`:`前后的有效的二进制字符串
    - `sed -E 's/ ([01]+)/ $((2#\1))/g'`: 借助双小括号`(())`将二进制字符串转换成10进制.
2. [How to print first 10 bytes in hexadecimal of a file?](https://superuser.com/questions/706101/how-to-print-first-10-bytes-in-hexadecimal-of-a-file)
    - 打印一个文件的前10个字节, 对于分析不同格式的文件的文件头时应该十分有用.

`xxd`与`od`是linux平台下少有的**字节操作**工具. 一般来说, linux的各种命令都是基于ascii等可见字符的操作(获取长度, 字符串截取等).

但涉及到中文字符的编码转换, 或者一些二进制操作, 又或者查看不同二进制文件的文件头信息(图片, 文本的前n个字节包含文件元信息), 就需要`xxd`, `od`命令了.

这里我们以中文字符的编码转换为例, 看看ta们两个的使用方法.

## 认知

```bash
## A的ASCII值为41, a的则为61
echo -ne "\\x41\\x42\\x43 \\x61\\x62\\x63"      ## ABC abc
printf '%b' "\\x41\\x42\\x43 \\x61\\x62\\x63"   ## ABC abc
```

`echo`的`-e`选项可以让命令行可以解释`\x61`这种格式的字符, 将其输出为二进制而不是当成纯字符输出. 

`printf`也是这个原理.

还有一些不可见字符, 仍然可以用`\xxx`这种格式表示比如bash中的彩色打印就需要`-e`选项.

```bash
echo -e "\033[31m 中国 \033[0m"
```

看看如何打印中文

```bash
echo -ne "\\xe4\\xb8\\xad \\xe5\\x9b\\xbd"      ## 中 国
printf '%b' "\\xe4\\xb8\\xad \\xe5\\x9b\\xbd"   ## 中 国
```

## 实际应用

我们在用浏览器访问一个包含中文字符的url时, 浏览器会自动将其转换为`%xx%yy`的格式. 各种高级语言也都提供了相应的编码函数, 如js中的`encodeURI()`, python3中的`urllib.parse.quote()`等.

其实原理都很简单, 就是将各个特殊字符(包含中文字符)转换成ta们在当前字符集的16进制表示而已.

```bash
echo -n abc | xxd -plain ## 616263, 分别是a, b, c的ASCII编码值.
echo -n 中国 | xxd -plain ## e4b8ade59bbd, 这里转换的是utf8编码, 每个汉字一般为3个字节
echo -n 中国 | xxd -plain | sed 's/\(..\)/%\1/g' ## %e4%b8%ad%e5%9b%bd sed为每两个字符前都添加上百分号%
```

转回

```bash
var='%e4%b8%ad%e5%9b%bd'
echo -ne ${var//%/\\x}      ## 中国
printf '%b' ${var//%/\\x}   ## 中国
```

`xxd`, `od`本质上都是读取二进制字节, 然后将其转换成其他进制的字符表示, 如果想要将其他进制的字符串转换成某一指定进制, 可能还需要借助`printf`, `bc`等命令. 当然, 这只是针对可见字符而言.

另外`xxd`只能进行二进制和十六进制间的编码互转, 而`od`则更灵活一点, 可以指定任意进制, 且输出格式更灵活.
