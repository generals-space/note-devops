# Linux命令-curl 上传文件

参考文章

1. [curl 模拟 GET\POST 请求, 以及 curl post 上传文件](https://blog.csdn.net/fungleo/article/details/80703365)
2. [ES 官方文档 Loading Sample Data](https://www.elastic.co/guide/en/kibana/5.5/tutorial-load-dataset.html)
    - `--data-binary`上传
3. [Curl命令的data, data-ascii, data-binary, data-raw和data-urlencode选项详解](https://blog.csdn.net/taiyangdao/article/details/77020762)

```
curl localhost:8000/api/upload -F "file=@/Users/general/Downloads/logo.png"
```

`-F`, `--form`选项, 模拟发送表单，默认即`POST`，且默认`Content-Type:multipart/form-data`.

`file`字段即是在前端form组中`<input type="file" name="file">`的`name`属性, 后端可以通过这个`name`名称获得文件流. 

`@路径`: 其中路径可以是相对路径.

不需要指定`-X POST`, `-F`的作用和ta是平级且互斥的.

------

上面是针对使用`submit`按钮, 通过前端表单上传的方式, 需要后端的配合.

如果后端只是单纯地接受POST上传的文件, 则需要使用`--data-binary`选项.

```
curl -H 'Content-Type: application/json' -XPOST 'localhost:9200/upload' --data-binary @file.json
```

...`Content-Type`可能得是 multipart 之类的, 用到的时候再说吧.
