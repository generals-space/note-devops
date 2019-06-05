# Shell脚本元素-各种括号(一)-反引号``与$()

参考文章

[Shell中反引号（`）与$()用法的区别](http://blog.csdn.net/apache0554/article/details/47055827)

## 4. ``与$()

[Shell中反引号（`）与$()用法的区别](http://blog.csdn.net/apache0554/article/details/47055827)

反引号\`\`与`$()`都被用做行内执行, 但它们其实是有区别的.

```
$ echo  `echo \$HOSTNAME`
localhost.localdomain
$ echo $(echo \$HOSTNAME)
$HOSTNAME
```

我们将上述代码写到脚本文件中, 使用`bash -x`选项分析它的执行过程

```
$ bash -x 脚本名
++ echo localhost.localdomain
+ echo localhost.localdomain
localhost.localdomain
++ echo '$HOSTNAME'
+ echo '$HOSTNAME'
$HOSTNAME

```

可以看到, 反引号中`\$`并没有将`$`的特殊意义转换, `echo \$HOSTNAME`仍然被解释为`echo $HOSTNAME`, 这就可以认为, 在反引号中`\`本身就是特殊字符, 直接被忽略掉. 所以取到了这个变量的值并输出, 所以反引号返回的值为`localhost.localdomain`.

`$()`则正好相反，`\$`明显被`\`转义成了一个普通字符，所以并没有取到变量值，而是返回了字符串本身的意思，故而返回了`$HOSTNAME`字符串.

如果要在反引号中输出`$HOSTNAME`字符串, 而在`$()`中输出`$HOSTNAME`的值, 要怎么做?

```
$ echo `echo \\$HOSTNAME`
$HOSTNAME
$ echo $(echo $HOSTNAME)
localhost.localdomain
$ echo $(echo \\$HOSTNAME)
\localhost.localdomain
```

反引号是老的用法，$()是新的用法，不管是在学习测试中，还是在实际工作中，$()的用法都是被推荐的.