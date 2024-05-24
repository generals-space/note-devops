# Linux命令-curl -f选项将4xx与5xx视为失败

参考文章

1. [Can I make cURL fail with an exitCode different than 0 if the HTTP status code is not 200?](https://superuser.com/questions/590099/can-i-make-curl-fail-with-an-exitcode-different-than-0-if-the-http-status-code-i)
2. [Curl to return http status code along with the response](https://stackoverflow.com/questions/38906626/curl-to-return-http-status-code-along-with-the-response)
3. [Getting curl to output HTTP status code?](https://stackoverflow.com/questions/38906626/curl-to-return-http-status-code-along-with-the-response)


在http协议中, 响应码只是响应头的一部分, 并不能代表响应体的状态, 尤其是当给出响应体内容的后端程序与生成响应码的反向代理服务器分离的时候.

有时候对于一个指定的uri, 我们只期望curl能够返回正确的200响应, 其他403, 404, 500, 502, 504等全都视为错误, 尤其是该uri用作健康检查接口的时候.

参考文章1, 2, 3的问答中给出了很多思路.

第一种最简单, 使用`-f`/`--fail`选项, ta会直接把4xx, 5xx的响应码都视作错误, exit退出码指定为22.

```log
$ curl -f localhost:9090
ok
$ curl -f localhost:9090
curl: (22) The requested URL returned error: 404
$ curl --fail localhost:9090
curl: (22) The requested URL returned error: 404
$ curl --fail localhost:9090
curl: (22) The requested URL returned error: 403
$ curl -f localhost:9090
curl: (22) The requested URL returned error: 500
$ echo $?
22
```

第二种就是使用`-w`选项打印指定响应头字段

```
curl -o /dev/null -s -w "%{http_code}" localhost:9090
```

第三种是使用`-I`打印所有响应头, 之后用grep等命令二次处理.

...我选第一种!
