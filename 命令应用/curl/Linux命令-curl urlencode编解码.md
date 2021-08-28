# Linux命令-curl urlencode编解码

参考文章

1. [curl 如何传递多参数并进行urlencode](https://segmentfault.com/q/1010000008630196)
2. [shell 下 urlencode/urldecode 编码/解码的几种方法](https://blog.csdn.net/carlostyq/article/details/7928610)
    - shell实现的encode方案
3. [github gist urlencode/urldecode](https://gist.github.com/cdown/1163649)

`curl`有`--data-urlencode`选项, 可以编码get请求的query string(post请求时会有些许不同)

下面两个命令等价

```
curl www.baidu.com/s?wd=手机
curl --get --data-urlencode 'wd=手机' www.baidu.com/s
```

但ta对于url中的path路径是没有办法的.

某些http服务器不接受中文路径, `curl http://www.test.com/手机.html`无法找到目标网页, 还是需要手动将中文字符进行编码.

js中有`encodeURI()`, python3有`urllib.parse.quote()`, 都可以实现编码的功能. 但是shell中是没有的, 所以需要手动编码.

shell的实现可以见参考文章2和3.
