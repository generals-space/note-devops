# 1. linux安装微软雅黑等字体

参考文章

[linux安装微软雅黑等字体](http://blog.csdn.net/zhaoweitco/article/details/6419886)

## 1.1 试验环境:

字体源文件来自: Win7

目标Linux平台: Fedora24

## 1.2 安装步骤

windows平台下, 打开 `控制面板`-> `外观和个性化` -> `字体`, 然后`Ctrl + f`搜索要找的字体, 比如`微软雅黑`, 右键复制出来.

将复制出来的字体传到linux平台下 `/usr/share/fonts/chinese/TrueType` 目录(可能chinese/TrueType不存在, 手动创建即可).

然后建立字体缓存, 执行以下命令

```shell
cd /usr/share/fonts/chinese/TrueType
mkfontscale
mkfontdir
fc-cache -fv
```

重启或重新登录, 即可生效.

## 1.3 测试方式

创建一个html文件, 这里取名为font.html, 写入以下代码, 在浏览器中打开, 可以看到效果.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>字体显示</title>
    <style media="screen">
      .msyh{
        font-family: "Micorsoft Yahei";
      }
      .simsun{
        font-family: "宋体";
      }
      .simhei{
        font-family: "黑体";
      }
    </style>
  </head>
  <body>
    <span class="msyh">我是微软雅黑</span>
    <br/>
    <span class="simsun">我是宋体</span>
    <br/>
    <span class="simhei">我是黑体</span>
    <br/>
  </body>
</html>

```
