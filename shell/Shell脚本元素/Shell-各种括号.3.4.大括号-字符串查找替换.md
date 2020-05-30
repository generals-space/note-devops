# Shell-各种括号.3.4.大括号-字符串查找替换

就是精确匹配后替换啦.

- `${var/str/newstr}`: 变量`var`包含`str`字符串, 则只有第一个`str`会被替换成`newstr`;
- `${var//str/newstr}`: 变量`var`包含`str`字符串, 则全部的`str`都会被替换成`newstr`;

```bash
var='hello world'
echo ${var/o/i}     ## helli world
echo ${var//o/i}    ## helli wirld
```

同样, 这两种方法也不会修改原变量`var`的值, 并且也可以使用通配符, 不过只能使用`?`与`*`.

```bash
var='hello world'
echo ${var/?o/ii}       ## helii world
echo ${var//?o/ii}      ## helii iirld
```
