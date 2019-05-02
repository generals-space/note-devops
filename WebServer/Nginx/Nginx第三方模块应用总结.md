# Nginx第三方模块应用总结

[官方项目地址](https://github.com/openresty/echo-nginx-module)

[官方安装手册](https://github.com/openresty/echo-nginx-module/blob/master/README.markdown#installation)

[使用版本](https://github.com/openresty/echo-nginx-module/blob/master/README.markdown#compatibility)

## 使用方法

安装方法网上遍地都是, 也蛮简单, 却少有人谈使用方法. 惭愧刚开始还以为echo会把输出显示在浏览器的响应头中.

首先, 在配置文件中的某一location块设置echo指令之后, 重启Nginx.

```
location / {
        echo "args: $args";
        echo "query_string: $query_string";
        echo "uri: $uri";
        echo "request_uri: $request_uri";
        echo "document_root: $document_root";
        echo "request_filename: $request_filename";
        echo "fastcgi_script_name: $fastcgi_script_name";
        echo "request_body_file: $request_body_file";
        echo "document_uri: $document_uri";
        echo "request: $request";
        try_files $uri $uri/ /index.php?$args;
}
```

用浏览器访问是可以的, 但echo的结果会作为文件被下载下来. 用文本编辑器打开, 你会发现你要的结果就在里面. 但这样有些麻烦.

正确的使用方式是用curl访问目标路径, echo的结果将被打印到控制台.

```
[root@localhost conf]# curl localhost/index.php?a=123
args: a=123
query_string: a=123
uri: /index.php
request_uri: /index.php?a=123
document_root: /var/www/html
request_filename: /var/www/html/index.php
fastcgi_script_name: /index.php
request_body_file: 
document_uri: /index.php
request: GET /index.php?a=123 HTTP/1.1
```

PS:

echo模块用来学习Nginx配置中的变量含义, 还有rewrite的处理规则是一个神器.

在未使用这个模块时, 使用Nginx的日志也是可以的, 因为Nginx的日志输出也可以使用变量形式.

前者方便直观, 后者不用编译安装, 各有优劣吧.

------

2016-09-20更新

不如使用nginx的`add_header`指令, 将要输出的信息添加到自定义响应头中, 配合`curl`的`-I`选项, 只输出访问响应头, 可以达到与`echo`模块相同的效果.