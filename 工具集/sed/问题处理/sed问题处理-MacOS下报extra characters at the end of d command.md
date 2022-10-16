# sed-MacOS下报extra characters at the end of d command

参考文章

1. [sed: 1: "grep": extra characters at the end of g command----sed on mac](https://blog.csdn.net/u013174217/article/details/65630712)

## 场景描述

```console
$ sed -i 's/127.0.0.1/mysql-svc/g' disconf-config/jdbc-mysql.properties
sed: 1: "disconf-config/jdbc-mys ...": extra characters at the end of d command
```

macOS下执行sed报上述错误, 按照参考文章1中所说, 在mac中使用sed命令在-i参数后面需要带一对引号, 单双都行, 正确格式如下:

```
sed -i '' 's/127.0.0.1/mysql-svc/g' disconf-config/jdbc-mysql.properties
```

## 原因分析

`sed -i`后面的引号中可写任意字符串或者为空, 含义是用于生成源文件的备份文件的文件名. 比如: `sed -i '_tmp' 's/a/b/g' test.sql`, 在替换`test.sql`的同时, 还会生成`test.sql_tmp`的备份文件.
