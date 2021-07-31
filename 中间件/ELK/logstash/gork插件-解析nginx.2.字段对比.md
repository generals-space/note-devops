# gork插件-nginx字段对比

1. [logstash grok插件语法介绍](https://blog.csdn.net/qq_34021712/article/details/79746413)
    - grok 自定义匹配模式
    - Grok过滤器配置选项: `add_field`, `reomve_field`, `add_tag`, `remove_tag`等的介绍与使用方法
2. [logstash之grok过滤](https://blog.csdn.net/yanggd1987/article/details/50486779)
    - 我们的生产环境中，日志格式往往使用的是普通的格式，因此就不得不使用logstash的filter/grok进行过滤
    - nginx 配置中的 log_format 内置变量与 grok 模式的对应关系, 值得收藏.
3. [logstash-plugins/logstash-patterns-core](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)
    - logstash 附加的 grok 模式(不过没有 nginx 的)
4. [grok在线匹配验证](http://grokconstructor.appspot.com/do/match)
    - 参考文章2中提到该网站, 并给出了使用示例.

`grok`本质是一种正则匹配库, 上述`match`规则中, `${IP:client}`将以`IP`类型匹配`172.19.0.1`格式的内容, 并将其值赋给`client`字段. 同理`HTTPDATE`匹配了`13/Oct/2020:10:55:05 +0000`的类型.

Logstash 提供了用于采集不同服务日志的 grok 模式(pattern), 如 `httpd(apache)`, `redis`, `postgresql`等, 但是没有`nginx`...

作为初学者, 对 logstash 的这些模式的使用肯定还不熟练, 自己筛选的话可能要花很长时间, 好在我找到了参考文章2, 这篇文章提供了`nginx`配置文件中`log_format`中各字段值与 logstash 模式的映射关系.

| nginx日志字段定义           | nginx访问字段                            | 正则表达式                    |
| :-------------------------- | :--------------------------------------- | :---------------------------- |
| $time_local                 | 08/Jan/2016:08:27:43 +0800               | %{HTTPDATE:timestamp}         |
| $upstream_addr              | 10.10.6.212:8088                         | %{HOSTPORT:upstream}          |
| `$server_addr:$server_port` | 10.10.6.110:80                           | %{HOSTPORT:request_server}    |
| $request_method             | GET                                      | %{WORD:request_method}        |
| $uri                        | /vvv/test/stat/index                     | %{URIPATH:uri}                |
| $request_uri                | /vvv/test/stat/index?a=1&b=2             | %{URIPATHPARAM:request}       |
|                             | `?a=1&b=2`                               | %{URIPARAM:args}              |
| $remote_addr                | 10.10.6.10                               | %{IP:clientip}                |
| $server_protocol            | HTTP/1.1                                 | HTTP/%{NUMBER:httpversion}    |
| `[$http_user_agent]`        | `[Mozilla/5.0 (Windows NT 6.3;)...]`     | `\[%{GREEDYDATA:agent}\]`     |
| `[$http_cookie]`            | `[JSESSIONID=kq3v6xi2b74j1a9yxvfvcq131]` | `\[%{GREEDYDATA:cookie}\]`    |
| $http_referer               | `http://10.10.6.110/test`                | `(?:%{URI:referrer}|-)`       |
| $host                       | `www.test.com`                           | %{HOSTNAME:domain}            |
| $status                     | 200                                      | %{NUMBER:status:int}          |
| $bytes_sent                 | 485                                      | %{NUMBER:body_sent:int}       |
| $request_length             | 209                                      | %{NUMBER:request_length:int}  |
| $request_time               | 1.642                                    | %{NUMBER:request_time:float}  |
| $upstream_response_time     | 1.642                                    | %{NUMBER:response_time:float} |

> 注意`nginx`日志中可能出现`""`双引号, `[]`中括号等, 需要使用`\`反斜线转义.

假设 nginx 日志格式如下

```
172.19.0.1 - - [13/Oct/2020:10:55:05 +0000] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36 Edg/85.0.564.44"
```

我们可以使用如下`grok`规则进行捕获

```conf
filter {
    grok {
        match => { 
            "message" => "%{IP:client} - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
```

------

关于`URIPARAM`正则, `nginx`中的`$args`与`$query_string`得到的都是`a=1&b=2`, 没有前面的`?`问号, 而`URIPARAM`只能捕获前面带`?`的内容.

所以, 对于`request_uri`生成的`/vvv/test/stat/index?a=1&b=2`信息, 除了使用`%{URIPATHPARAM:uri}`, 还可以使用`%{URIPATH:uripath}(%{URIPARAM:uriargs})?`捕获(末尾的`?`表示0或1次).
