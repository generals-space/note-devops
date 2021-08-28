# ASCII, 二进制与中文编码转换.1.xxd

参考文章

1. [在bash中，我怎样才能从二进制转换为utf8？](https://cloud.tencent.com/developer/ask/138070)
    - `sed -E 's/.*:(( [01]+){0,6}).*/\1/'`: 截取`:`前后的有效的二进制字符串
    - `sed -E 's/ ([01]+)/ $((2#\1))/g'`: 借助双小括号`(())`将二进制字符串转换成10进制.
2. [How to print first 10 bytes in hexadecimal of a file?](https://superuser.com/questions/706101/how-to-print-first-10-bytes-in-hexadecimal-of-a-file)
    - 打印一个文件的前10个字节, 对于分析不同格式的文件的文件头时应该十分有用.

## `-plain`无前缀输出

```bash
echo -n abc | xxd 
## 0000000: 6162 63                                  abc
```

由于我们一般不需要前缀的`000000`, 所以通常都会为`xxd`添加`-plain`选项屏蔽ta.

```bash
echo -n abc | xxd -plain ## 616263
```

## `-u`大写的16进制字符

```bash
echo -n jkl | xxd -plain    ## 6a6b6c
echo -n jkl | xxd -plain -u ## 6A6B6C
```

## `-r`/`-revert`转回原字符串

```bash
echo -n 616263 | xxd -r -plain          ## abc
echo -n 6A6B6C | xxd -r -plain          ## jkl
echo -n e4b8ade59bbd | xxd -r -plain    ## 中国
```

> 反向转换不需要指定`-u`选项.

## `-b`/`-bits`二进制格式

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
