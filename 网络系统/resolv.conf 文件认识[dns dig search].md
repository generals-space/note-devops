# resolv.conf 文件认识[dns dig search]

参考文章

1. [Linux中/etc/resolv.conf文件简析](https://blog.csdn.net/lcr_happy/article/details/54867510)


nameserver:     定义DNS服务器的IP地址
domain:         定义本地域名
search:         定义域名的搜索列表
sortlist:       对返回的域名进行排序

最主要是nameserver关键字，如果没指定nameserver就找不到DNS服务器，其它关键字是可选的。
nameserver表示解析域名时使用该地址指定的主机为域名服务器。其中域名服务器是按照文件中出现的顺序来查询的,且只有当第一个nameserver没有反应时才查询下面的nameserver，一般不要指定超过3个服务器。

domain声明主机的域名 很多程序用到它，如邮件系统；当为没有域名的主机进行DNS查询时，也要用到。如果没有域名，主机名将被使用，删除所有在第一个点( .)前面的内容。

search它的多个参数指明域名查询顺序 当要查询没有域名的主机，主机将在由search声明的域中分别查找。
domain和search不能共存；如果同时存在，后面出现的将会被使用。

sortlist允许将得到域名结果进行特定的排序 它的参数为网络/掩码对，允许任意的排列顺序。

“search domainname.com”表示当提供了一个不包括完全域名的主机名时，在该主机名后添加domainname.com的后 缀；“nameserver”表示解析域名时使用该地址指定的主机为域名服务器。其中域名服务器是按照文件中出现的顺序来查询的。
其中domainname和search可同时存在，也可只有一个。

> Red Hat中没有提供缺省的/etc/resolv.conf文件，它的内容是根据在安装时给出的选项动态创建的。

