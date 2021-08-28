# Linux命令-curl

参考文章

1. [Linux curl命令参数详解](http://www.aiezu.com/system/linux/linux_curl_syntax.html)
2. [在linux下使用curl访问 多参数url GET参数问题](http://blog.csdn.net/sunbiao0526/article/details/6831327)
3. [shell curl 数据中含有空格 如何提交](https://blog.csdn.net/qq_25279717/article/details/71577313)

```
curl -H "Content-Type: application/json" -X POST -d '{"name":"general","password":"123456"}' -k http://localhost/login
```

`-H '请求头'`: 添加请求头信息
`-X POST|HEAD|OPTION`: 可以明确指定请求类型.
`-d`: 指定数据, 此选项出现时请求类型自动变为`POST`(**注意: 默认的`Content-Type`为`application/x-www-form-urlencoded`, 一般需要显式指定`application/json`**)
`-k`: 如果是https且证书不合法时, 可以使用`-k`忽略对目标网站的证书验证(或`--insecure`);
`-s`: 静默输出(有些发行版会打印请求时间, 传输速度和下载进度等信息, 可以使用此选项屏蔽);
`-o 文件路径`: 将请求得到的数据写入目标文件
`-O`: 将请求得到的数据写入文件, 文件名与远程请求的文件名相同, 这需要目标url不是以`/`结尾而应该是一个文件比如`index.php`.
`-w '格式化字符串'`: 指定curl得到的信息及格式.

**url中请求参数中`&`的处理**

假设url为`http://localhost/index.php?a=1&b=2&c=3`, 浏览器中访问此地址, 后端程序可以在后台获取到所有的参数.

如果直接使用`curl`访问, 后端程序只能获取到参数`a`. 由于url中有`&`, 命令会被放到后台执行, 其他参数获取不到, 必须对`&`进行下转义.

```
curl http://localhost/index.php?a=1\&b=2\&c=3
```

**form格式与json格式的数据模拟**

`form`格式的数据需要是`key=value&key=value`, 而`json`格式则是常规的字典形式.

```
$ curl -X POST -d 'method=login' -H 'Content-Type: application/x-www-form-urlencoded' localhost/api/admin.php
$ curl -X POST -d '{"method":"login"}' -H 'Content-Type: application/json' localhost/api/admin.php
```
