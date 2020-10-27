# grok插件-redis

参考文章

1. [linuxea:ELK5.5-redis日志grok处理(filebeat)](https://www.linuxea.com/1713.html)

redis 日志中, 表示日志级别的不是用 debug, info 等单词, 而是`.`, `*`, `#`等符号

- `.`: debug
- `-`: verbose
- `*`: notice
- `#`: warring

