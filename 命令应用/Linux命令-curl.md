# Linux命令-curl

<!tags!>: <!代理!>

参考文章

1. [Linux curl命令参数详解](http://www.aiezu.com/system/linux/linux_curl_syntax.html)

2. [在linux下使用curl访问 多参数url GET参数问题](http://blog.csdn.net/sunbiao0526/article/details/6831327)

3. [shell curl 数据中含有空格 如何提交](https://blog.csdn.net/qq_25279717/article/details/71577313)

4. [curl 模拟 GET\POST 请求, 以及 curl post 上传文件](https://blog.csdn.net/fungleo/article/details/80703365)

## 1. 常用选项

```
curl -H "Content-Type: application/json" -X POST -d '{"name":"general","password":"123456"}' -k http://localhost/login
```

`-H '请求头'`: 添加请求头信息
`-X POST|HEAD|OPTION`: 可以明确指定请求类型.
`-d`: 指定数据, 此选项出现时请求类型自动变为`POST`(**注意: 默认的`Content-Type`为`application/x-www-form-urlencoded`, 一般需要显式指定`application/json`**)
`-k`: 如果是https且证书不合法时, 可以使用`-k`忽略对目标网站的证书验证;
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
curl -X POST -d 'method=login' -H 'Content-Type: application/x-www-form-urlencoded' localhost/api/admin.php
curl -X POST -d '{"method":"login"}' -H 'Content-Type: application/json' localhost/api/admin.php
```

## 2. 使用`-H`添加请求头信息: `User-Agent`与`Cookie`

可以分别使用`--cookie`, `--user-agent`配置, 也可以直接使用`-H 'User-Agent: UA字符串'`的形式.

```
curl -I -H 'Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36' www.baidu.com
```

但是有一点需要注意, 'Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;'字符串不能作为一个变量传入, `User-Agent`同理, 因为这样curl执行会报错. 如下

```
cookie_str='Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;'
ua_str='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
curl -I -H $cookie_str -H $ua_str www.baidu.com
curl: (6) Could not resolve host: _ga=GA1.2.1337029376.1526882292;
...
```

通过变量传入的字符串会被以空格分隔开, 所以会出错...不过直接将这么长的字符串写在行内也真够low的.

## 3. 上传文件

```
curl localhost:8000/api/upload -F "file=@/Users/general/Downloads/logo.png"
```

`file`字段即是在前端form组中`<input type="file" name="file">`的`name`属性, 后端可以通过这个`name`名称获得文件流. 

`@路径`: 其中路径可以是相对路径.

不需要指定`-X POST`, `-F`的作用和ta是平级且互斥的.

## 4. 代理设置

```
## 普通的http代理
$ curl -x 127.0.0.1:3128 www.google.com

## socks5代理
$ curl --socks5 127.0.0.1:1080 www.google.com
```

使用wget达到同样的效果

```
$ wget -Y on -e 'http_proxy=http://10.10.10.10:10' 'www.google.com'
```

- `-Y`: 是否使用代理; 
- `-e`执行命令;

> `wget`只有http代理, 不能直接使用`socks`代理.

## 5. `-w`选项指定输出格式

curl命令内置了许多输出, 如状态码, 抓取速度, 总时间等, 可通过`-w`选项选择性输出.

```shell
## 输出抓取百度首页的平均速度
$ curl -s -o /dev/null -w '%{speed_download}\n' www.baidu.com
61669.000
## 平均速度与总时间
$ curl -s -o /dev/null -w '--%{speed_download}--%{time_total}--\n' www.baidu.com
--96451.000--0.025--
```

其他可使用的字段可以参见curl命令的man手册.
