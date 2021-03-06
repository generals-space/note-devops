# ASCII, 二进制与中文编码转换-xxd与od

参考文章

1. [在bash中，我怎样才能从二进制转换为utf8？](https://cloud.tencent.com/developer/ask/138070)
    - `sed -E 's/.*:(( [01]+){0,6}).*/\1/'`: 截取`:`前后的有效的二进制字符串
    - `sed -E 's/ ([01]+)/ $((2#\1))/g'`: 借助双小括号`(())`将二进制字符串转换成10进制.
2. []
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

## `xxd`命令应用

### `-plain`无前缀输出

```bash
echo -n abc | xxd 
## 0000000: 6162 63                                  abc
```

由于我们一般不需要前缀的`000000`, 所以通常都会为`xxd`添加`-plain`选项屏蔽ta.

```bash
echo -n abc | xxd -plain ## 616263
```

### `-u`大写的16进制字符

```bash
echo -n jkl | xxd -plain    ## 6a6b6c
echo -n jkl | xxd -plain -u ## 6A6B6C
```

### `-r`/`-revert`转回原字符串

```bash
echo -n 616263 | xxd -r -plain          ## abc
echo -n 6A6B6C | xxd -r -plain          ## jkl
echo -n e4b8ade59bbd | xxd -r -plain    ## 中国
```

> 反向转换不需要指定`-u`选项.

### `-b`/`-bits`二进制格式

```bash
echo -n abc | xxd -b 
## 0000000: 01100001 01100010 01100011                             abc
```

在使用`-b`选项时, `-plain`无效, 所以需要手动处理前缀`000000`和间隔字符.

这里给出可用的截取命令.

```bash 
echo -n abc | xxd -b | sed -E 's/.*:(( [01]+){0,6}).*/\1/' ## 01100001 01100010 01100011
```

但是二进制字符串是没有办法再转换回

```bash
echo -n '01100001 01100010 01100011' | xxd -r -plain ## 无输出
```

只能将二进制字符串转换成16进制, 再通过`-r`转回. 参考文章1中给出了相应的解决方案.

## `od`命令应用

### 编码转换

```bash
echo -n abcdefghijklmnoprs | od -tx
## 0000000 64636261 68676665 6c6b6a69 706f6e6d
## 0000020 00007372
## 0000022
```

`od`的输出将会像一些工具(比如winhex, 或是wireshark)中的16进制查看区域一样进行排列, 默认一行16个(可使用`-w`选项调整). 第一列是地址列, 起始为`000000`(这一点和`xxd`很像), 最后一行为空行, 且该行的第一列表示结束地址.

### `-A`起始地址

与`xxd`一样, 我们也经常只需要纯输出, 不需要显示地址(或者说偏移量).

```bash
echo -n abcdefghijklmnoprs | od -tx -An
## 64636261 68676665 6c6b6a69 706f6e6d
## 00007372
```

`-A`/`--address-radix`: 表示的其实是第1列的地址显示格式, 因为每行的字节数默认是16, 所以每行的地址列显示的都是16的倍数(除了最后一行)
    - `n`: 表示不显示第1列的地址(上面已给出示例)
    - `d`: 十进制. 上面的命令第1列的输出分别为`0000000`, `0000016`, `0000018`
    - `o`: 八进制(默认). 上面的命令第1列的输出分别为`0000000`, `0000020`, `0000022`
    - `x`: 十六进制. 上面的命令第1列的输出分别为`000000`, `000010`, `000012`.

### `-t`/`--format`输出格式

`-t`表示要输出的格式, 可选的有(可指定多个, 这样每行输入都会有多行不同格式的输出, 作为对比打印出来)
    - `a`: ASCII, 不可见字符将以指定的名称显示, 比如换行将显示为`nl`)
    - `c`: 默认字符集中的字符, 如果指定了这个标记, 换行将直接显示为`\n`, 更直观.
    - 按指定进行显示各字节, 这一类包含: `d`(十进制), `o`(八进制), `u`(无符号十进制...???我call), `x`(十六进制). man手册还规定, 使用此类显示方式时, 可以指定各字节的组合长度, 默认是4个字节为一组(比如上面的`-tx`). 组合长度可选的有`C`(char单字节), `S`(short双字节), `I`(int四字节), `L`(long八字节), 也可以手动指定ta们(C|S|I|L)的数字表示(1, 2, 4, 8)比如`-tx4`.

```bash
## 这是换行实例
echo | od -An -ta   ## nl
echo | od -An -tc   ## \n
echo | od -An -txC  ## 0a
```

```bash
echo -n 中国 | od -An -ta   ##    d   8   -   e esc   =
echo -n 中国 | od -An -tc   ##  344 270 255 345 233 275
echo -n 中国 | od -An -txC  ##  e4 b8 ad e5 9b bd
```
