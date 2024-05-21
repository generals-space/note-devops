# 搜索引擎-robots.txt协议详解

参考文章

1. [robots.txt的语法和写法详解](http://www.cnblogs.com/top5/archive/2011/07/30/2121881.html)
2. [详细的robots.txt学习方法](http://www.chinaz.com/web/2011/1117/221058.shtml)
3. [在线网站robots.txt文件生成器 - aTool在线工具](http://www.atool.org/robots.txt.php)

robots.txt严格来说并不算是一个可靠的协议, 它是一个纯文本文件, 是搜索引擎蜘蛛爬行网站的时候要访问的第一个文件. 当蜘蛛访问一个站点时, 它会首先检查该站点根目录下是否存在`robots.txt`, 如果存在, 搜索机器人就会按照该文件中的内容来确定访问的范围, 相当于网站与搜索引蜘蛛遵循协议, 如果该文件不存在, 所有的搜索蜘蛛将能够访问网站上所有没有被屏蔽的网页. 作为站长, 我们就可以通过`robots.txt`文件屏蔽掉错误的页面和一些不想让蜘蛛抓取和收录的页面.

由于一些系统中的URL是大小写敏感的, 所以robots.txt的文件名应统一为小写. robots.txt应放置于网站的根目录下. 

## 1. 语法

1. `User-agent`: 定义搜索引擎. 一般情况下, 网站里面都是: `User-agent: *`, 这里`*`的意思是所有, 表示允许所有的搜索引抓取. 如果只允许百度, 那么就是`User-agent: Baiduspider`; 允许google, 则`User-agent: Googlebot`. 

2. `Disallow`: 禁止抓取. 如想禁止搜索引擎抓取我的admin目录, 那就是`Disallow: /admin/`. 禁止抓取admin目录下的login.html, `Disallow: /admin/login.html`. 

3. `Allow`: 允许. 在默认情况下, 所有链接页面都是被允许访问的. 那为什么还要允许这个语法呢? 举个例子: 我想禁止admin目录下的所有文件, 除了`.html`的网页, 那怎么写呢? 我们知道可以用`Disallow`一个一个禁止, 但那样太费时间很精力了. 这时候运用`Allow`就解决了复杂的问题, 就这样写: 

```
Allow: /admin/.html$
Disallow: /admin/. 
```

4. $: 结束符. 例: `Disallow: .php$` 这句话的意思是, 屏蔽所有的以`.php`结尾的文件, 不管前面有多长的URL, 如`abc/aa/bb//index.php`都是屏蔽的. 

5. `*`: 通配符符号0或多个任意字符. 例: `Disallow: *?*`这里的意思是屏蔽所有带'?'文件, 也是屏蔽所有的动态URL. 

## 2. 示例

### 2.1 允许指定搜索引擎抓取(节省服务器带宽)

下面的`robots.txt`只允许百度, 谷歌抓取, 其余搜索引擎禁止. `Disallow: `可以用`Allows: /`代替.

```
User-agent: Googlebot
Disallow: 
User-agent: baiduspider
Disallow: 
User-agent: MSNBot
Disallow: /
User-agent: Slurp
Disallow: /
User-agent: *
Disallow: /
```

### 2.2 禁止Spider访问特定目录和特定文件（图片、压缩文件）. 

```
User-agent: *
Disallow: /cgi-bin/
Disallow: /admin/
Disallow: .jpg$
Disallow: .rar$
```

这样写之后, 所有搜索引擎都不会访问这两个目录. 需要注意的是对每一个目录必须分开说明, 而不要写出“Disallow:/cgi-bin/ /admin/”. 

### 2.3 声明网站地图sitemap

告诉搜索引擎你的sitemap在哪, 如: 

```
Sitemap:  http://www.example.com/sitemap.xml
```

站点地图需要自行生成, 也可以寻找第三方工具.

## 3. robots.txt的好处与坏处

好处: 

1. 有了robots.txt, spider抓取URL页面发生错误时则不会被重定向至404处错误页面, 同时有利于搜索引擎对网站页面的收录. 
2. robots.txt可以制止我们不需要的搜索引擎占用服务器的宝贵宽带. 
3. robots.txt可以制止搜索引擎对非公开的爬行与索引, 如网站的后台程序、管理程序, 还可以制止蜘蛛对一些临时产生的网站页面的爬行和索引. 
4. 如果网站内容由动态转换静态, 而原有某些动态参数仍可以访问, 可以用robots中的特殊参数的写法限制, 可以避免搜索引擎对重复的内容惩罚, 保证网站排名不受影响. 

坏处: 

1. robots.txt轻松给黑客指明了后台的路径. 

解决方法: 给后台文件夹的内容加密, 对默认的目录主文件inde.html改名为其他. 

2. 如果robots.txt设置不对, 将导致搜索引擎不抓取网站内容或者将数据库中索引的数据全部删除. 

```
User-agent: *
Disallow: /
```

这一条就是将禁止所有的搜索引擎索引数据. 

## 4. 

**国内的搜索引擎蜘蛛**

- 百度蜘蛛: baiduspider
- 搜狗蜘蛛: sogou spider
- 有道蜘蛛: YodaoBot和OutfoxBot
- 搜搜蜘蛛:  Sosospider

**国外的搜索引擎蜘蛛**

- google蜘蛛:  googlebot
- yahoo蜘蛛: Yahoo！ Slurp
- alexa蜘蛛: ia_archiver
- bing蜘蛛（MSN）: msnbot

