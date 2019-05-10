# Kali-sqlmap

<!tags!>: <!sqlmap!>

参考文章

1. [SQLMap用户手册【超详细】](http://www.cnblogs.com/hongfei/p/3872156.html)

2. [渗透日记-利用SQLMAP伪静态注入](http://www.cnblogs.com/ximotao/p/5870274.html)

3. [Sqlmap注入技巧收集](http://www.freebuf.com/articles/web/10789.html)

## 自动注入

```
$ sqlmap -u http://192.168.1.150/products.asp?id=134
```

`-u`: 目标url

当给sqlmap这么一个url的时候，它会：

1. 判断可注入的参数, 一般按照`?a=1&b=2`这种形式分析.

2. 判断可以用那种SQL注入技术来注入.

3. 识别出哪种数据库, 如果你已经通过其他方法知道了数据库类型, 可以通过`--dbms`指定, 如`--dbms-mysql`

4. 根据用户选择，读取哪些数据. 你可以指定的选项在sqlmap帮助手册中的`Enumeration`节列出.

## 伪静态

一个普通意义上的url: `http://www.xxx.com/news.php?id=1`

做了伪静态之后就成这样了

http://www.xxx.com/news.php/id/1.html

这种类型sqlmap是没法识别到注入点的, 所以我们需要手动指定注入点, 如下.

```
$ sqlmap -u http://104.151.231.170/index.php?s=vod-search-wd-* --dbms=mysql
```

这里通过`--dbms`选项手动指定目标数据库类型为`mysql`, 并通过指定`*`符号标记注入点.

## POST类型

```
$ sqlmap.py -u "http://www.target.com/vuln.php" --data="id=1" --banner --current-user --current-db
```

`--data`: 可以指定post的数据.

`--banner`, `--current-user`, `--current-db`指定查询这3样数据: 数据库banner信息, 当前用户名, 当前数据库名, sqlmap会自动构造关于这3样信息的注入字符串, 但不一定能完全找到.
