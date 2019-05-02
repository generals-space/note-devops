# Nginx错误-499

情境描述:

前端发起`ajax`请求, nginx将请求转发到后端tomcat服务器, 10s后请求显示失败.

在没有显式设置`timeout`时间的nginx中, 其实这种情况一般不会是nginx引起的. 因为nginx的各种`timeout`时间大多是`60s`, 而`10s`的等待时间的确是太短了, 不应该是nginx主动断开.

499错误是什么？让我们看看NGINX的源码中的定义：

```c
ngx_string(ngx_http_error_495_page), /* 495, https certificate error */
ngx_string(ngx_http_error_496_page), /* 496, https no certificate */
ngx_string(ngx_http_error_497_page), /* 497, http to https */
ngx_string(ngx_http_error_404_page), /* 498, canceled */
ngx_null_string,                    /* 499, client has closed connection */
```

可以看到，499对应的是`client has closed connection`。这很有可能是因为服务器端处理的时间过长，客户端"不耐烦"了。

所以极有可能是前端对`ajax`请求设置了超时时间, 超时后断开连接并触发`abort`方法.