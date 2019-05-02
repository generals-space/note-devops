# Linux命令-sed

参考文章

1. [linux下在某行的前一行或后一行添加内容](http://www.361way.com/sed-process-lines/2263.html)

2. [老段带我学sed的笔记](http://foolishfish.blog.51cto.com/3822001/1376171)

3. [sed学习笔记](http://www.cnblogs.com/jcli/p/4088514.html)

4. [sed 匹配两行之间的行](http://blog.chinaunix.net/uid-10697776-id-2935704.html)

## 1. 追加append与插入insert

### 1.1 在某行的前一行或后一行添加内容

匹配行前插入(insert): `sed -i '/目标行匹配内容/i待添加新行内容' 目标文件`

匹配行后追加(append): `sed -i '/目标行匹配内容/a待添加新行内容' 目标文件`

在书写的时候为便与区分, 往往会在`i`和`a`后(新行内容前)加一个反斜扛.

匹配行前插入(insert): `sed -i '/目标行匹配内容/i\待添加新行内容' 目标文件`

匹配行后追加(append): `sed -i '/目标行匹配内容/a\待添加新行内容' 目标文件`

### 1.2 在某行(已知具体行号)前或后加一行内容

第4行前插入: `sed -i '4i待添加新行内容' 目标文件`

第4行后追加: `sed -i '4a待添加新行内容' 目标文件`

> 与上面一样, 也可以在`i`和`a`后加上反斜线`\`

**注意: 行号需要大于1, 不能等于**

以如下文件为例, `index.html`

```html
<html>
<head>
</head>

<body>
hello world
</body>
</html>
```

以下两行都无效

```
$ sed -i '1a\<!DOCTYPE>' ./index.html
$ sed -i '1i\<!DOCTYPE>' ./index.html
```

下面的才有效, 会在最开始添加`<!DOCTYPE>`这个标记

```
$ sed -i '2i\<!DOCTYPE>' ./index.html
```

然后`index.html`会被修改成

```
<!DOCTYPE>
<html>
<head>
</head>

<body>
hello world
</body>
</html>
```

也就是说, **`行号`中指定的行号实际上等于目标行号+1**. 简直...不可理喻.

## 2. `-s`单行内容修改

同样可以使用行号与匹配内容两种方式选择目标行, 在使用`s`替换时, 只会修改匹配到的内容, 因此可以实现部分替换.

移除所有行(如果以`#`开头)行首的`#`符号: `sed -in 's/^#//' filename`

移除第4-10行(如果以`#`开头)行首的`#`符号: `sed -in '4,10s/^#//' filename`

...不过给不以`#`开头的行添加上`#`要怎么做?

这就需要用到`sed` **分组**的能力了, 在另一篇文章里有介绍.

```
$ sed -i '4,10s/\(.*\)/#\1/' ./www.conf
```

## 3. `-p`打印

使用`-p`打印时一般需要配合`-n`选项, 只打印目标行, 忽略多余输出.

### 匹配两行之间

按行号匹配: `sed -n '3,5p' ./example.txt`

按包含内容匹配(一般是时间段), 贪心: `sed -n '/2017-03-06 04:00/,/2017-03-06 04:15/p' ./example.txt`

### 反向选择

`p`命令是打印匹配到的行, `!p`则是不打印匹配到的行. 这一用法类似于`grep`的`-v`选项.

`sed -n '3,5!p' ./example.txt`
