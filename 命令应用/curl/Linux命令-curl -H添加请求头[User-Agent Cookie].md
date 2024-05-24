# Linux命令-curl -H添加请求头[User-Agent Cookie]

可以分别使用`--cookie`, `--user-agent`配置, 也可以直接使用`-H 'User-Agent: UA字符串'`的形式.

```
curl -I -H 'Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36' www.baidu.com
```

但是有一点需要注意, 'Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;'字符串不能作为一个变量传入, `User-Agent`同理, 因为这样curl执行会报错. 如下

```log
$ cookie_str='Cookie: _ga=GA1.2.1337029376.1526882292; session_id=PvAvY-4CYs463Y;'
$ ua_str='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
$ curl -I -H $cookie_str -H $ua_str www.baidu.com
curl: (6) Could not resolve host: _ga=GA1.2.1337029376.1526882292;
...
```

通过变量传入的字符串会被以空格分隔开, 所以会出错(单双引号都不行)...不过直接将这么长的字符串写在行内也真够low的.
