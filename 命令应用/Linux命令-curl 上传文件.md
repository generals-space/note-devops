# Linux命令-curl 上传文件

参考文章

1. [curl 模拟 GET\POST 请求, 以及 curl post 上传文件](https://blog.csdn.net/fungleo/article/details/80703365)

```
curl localhost:8000/api/upload -F "file=@/Users/general/Downloads/logo.png"
```

`file`字段即是在前端form组中`<input type="file" name="file">`的`name`属性, 后端可以通过这个`name`名称获得文件流. 

`@路径`: 其中路径可以是相对路径.

不需要指定`-X POST`, `-F`的作用和ta是平级且互斥的.
