# Nginx错误-403 Forbidden

文章翻译自: 

[Resolving "403 Forbidden" error](http://nginxlibrary.com/403-forbidden-error/)

## 1. 引言

`403 Forbidden`错误是Nginx在告诉你, "你请求了一个资源(这个请求我已经收到了), 但我不能给你". 技术上讲, `403 Forbidden`并不是一种错误, 而是HTTP响应的一个状态码. 403响应会在某些情况下**有意**地传回, 比如:

1. 用户不允许访问该页面或资源, 或者整个网站;

2. 用户尝试访问一个目录, 然而`autoindex`被设置为`off`;

3. 用户试图访问一个只能从内部访问的文件;

这些是出现403响应的一些可能的情况, 但这里我们将要讨论的不是服务器有意响应403或者说, 我们并不希望看到403的情况, 这一般是服务器端配置错误导致的.

## 2. 权限配置不正确

这是发生此类错误较为普遍的原因. 这里的权限, 我并不是单单指被访问文件的权限. 为了向用户提供一个文件响应, Nginx需要拥有对该文件的`read(r)`权限, 并且还需要有该文件各级父目录的`excute(x)`权限. 举个例子, 为了访问这样一个文件:

```
/usr/share/myfiles/image.jpg
```

Nginx需要拥有这个文件的`r`权限, 还需要拥有对`/`, `/usr`, `/usr/share`, `/usr/share/myfiles`这些目录的`x`权限. 如果你设置这些目录的权限为标准的`755`, 该文件的权限为`644(umask: 022)`, 就不会出现这个403错误.

为了检查该路径上各级的属主和权限, 我们可以使用`namei`具, 像这样:

```
$ namei -l /var/www/vhosts/example.com

f: /var/www/vhosts/example.com
drwxr-xr-x root     root     /
drwxr-xr-x root     root     var
drwxr-xr-x www-data www-data www
drwxr-xr-x www-data www-data vhosts
drwxr-xr-x clara    clara    example.com
```

## 3. 目录的index选项未被正确定义

> PS:译者个人是因为index指令未配置

有些时候, `index`指令并没有包含我们希望的目录中的默认索引(index). 举例来说, 提供PHP程序响应的标准index指令应该设置为:

```
index index.html index.htm index.php;
```

在这个例子中, 当用户**直接访问一个目录时**, Nginx首先尝试响应该目录下的`index.html`, 如果不存在就去找`index.htm`, 然后是`index.php`. 如果都没有找到Nginx就会返回403的响应头. 如果index.php没有在`index`(原文中是`root`指令, 感觉...不太对)指令中定义, Nginx就不去查找`index.php`是否存在而直接返回`403`.

类似的, 如果是Python的服务, 你需要指定`index.py`为目录的默认索引.

These are the most common causes of undesired 403 responses. Feel free to leave a comment if you are still getting 403s.

If you find this article helpful, please consider making a donation.
