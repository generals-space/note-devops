# Linux命令-sed(三)正则

参考文章

1. [Why doesn't `\d` work in regular expressions in sed? [duplicate]](https://stackoverflow.com/questions/14671293/why-doesnt-d-work-in-regular-expressions-in-sed)
    - sed中`\d`无法表示`[0-9]`, 需要使用`[[:digit:]]`

`-r`: 使用扩展正则语法

`\<` 和 `\>`: 匹配单词边界

在使用sed的正则时, 常规正则中没有`+`号(匹配一次或多次), 只有`*`(匹配0次或多次)
