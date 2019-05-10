whatweb

WhatWeb是一款网站指纹识别工具，主要针对的问题是：“这个网站使用的什么技术？”WhatWeb可以告诉你网站搭建使用的程序，包括何种CMS系统、什么博客系统、Javascript库、web服务器、内嵌设备等。WhatWeb有超过900个插件，并且可以识别版本号、email地址、账号、web框架、SQL错误等等。

简单用法:whatweb URI

```
root@kali:~/Downloads# whatweb  104.151.231.170
http://104.151.231.170 [302 Found] Cookies[PHPSESSID], Country[UNITED STATES][US], HTTPServer[nginx], IP[104.151.231.170], PHP[5.6.30], RedirectLocation[index.html], X-Powered-By[PHP/5.6.30], nginx
http://104.151.231.170/index.html [200 OK] Country[UNITED STATES][US], Email[maye4438x@yahoo.com], HTTPServer[nginx], IP[104.151.231.170], JQuery[1.7.2], Script[text/javascript], Title[澳门赌场], nginx
```
