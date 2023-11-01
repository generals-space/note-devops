# ntpdate同步时间

参考文章

1. [Linux系统之时间同步方法](https://blog.csdn.net/jks212454/article/details/126151111)

我不想搭建时间服务器, 就想找个公共服务器定时同步而已.

```
yum install -y ntpdate
```

```
ntpdate ntp.aliyun.com
```
