# Linux高效输入

>借鉴于**`《像黑客一样使用命令行》`**

## 1. 组合命令查询手册

|               命令引用                 |               参数引用                |        参数修饰       |
|:--------------------------------------:|:-------------------------------------:|:---------------------:|
| ! [ ! \| [ ? ] 字符串 \| [ - ] 数字 ]  | : [ ^ \| $ \| \* \| n \| n\* \| x-y ] | : [ h \| t \| r \| e] |

### 1.1 命令修改

|||
|:---------------------------:|:-----------------------------------------------------:|
|`^string` \| `!:s/string/`   |   删除上一条命令中第1个匹配到的指定的字符串`string`   |
|`^old^new` \| `!:s/old/new`  |   替换上一条命令中输错或输少的部分, 也是只匹配第1个   |
|`!:gs/old/` \| `!:gs/old/new`|   将上一条命令中`old`部分全部删除或替换成`new`        |


------

关于命令修改, 要记住的是

- 一删
- 二换
- 三全变

### 1.2 命令引用

|||
|:----------:|:-----------------------------------------------------------------------------------:|
|`!!`        |重复上一条命令                                                                       |
|`!his`      |执行最近的以`his`开头的命令                                                          |
|`!?his`     |执行最近的包含`his`字符串的命令(看来跟`ctrl+r`作用相同)                              |
|`!n`        |执行第n个命令, 注意这个n不是倒数的, 而是按照`history`命令显示的序号来的              |
|`!-n`       |这个才是执行倒数第n个命令的(从1开始计数的哦), 即`!-1` == `!!`                         |
|`!#`        |引用当前行, 比如`!#:1`是当前行的第1个参数, 一般都是作为后面的参数引用前面的          |

------

关于命令引用, 要记住的是

- !!

- ![?]字符串

- ![-]数字

- !#

### 1.3 参数引用

|||
|:---------:|:-------------------------------------------------------------------:|
|`!$`       |代表上一条命令的最后一个参数|
|`!^`       |代表上一条命令的第一个参数(真的是参数, 也就是命令名不计算在内)|
|`!*`       |代表上一条命令的所有参数|
|`!:n`      |代表上一条命令第n个参数|
|`!:x-y`    |代表上一条命令从第x到第y个参数|
|`!:n*`     |代表上一条命令从 n 开始到最后的参数|

关于参数引用, 要记住的是

- n

- ^|$

- [n]*

- x-y

### 1.4 参数修饰

|||
|:-----:|:--------------------------------------------------------------------------------------------:|
|`:h`   |选取参数中的路径开头.(其实就是以`/`分割字符串)|
|`:t`   |选取参数中的路径结尾|
|`:r`   |选取参数中的文件名.(这个就是以`.`分割了)|
|`:e`   |选取参数中的扩展名.(说了是以`.`分割了, 如果是扩展名是`.tar.gz`的话, 这个东西就只能得到`gz`...)|

------


## 2. 使用实例

### 2.1 初级

#### 2.1.1

删除上一条命令中的多余部分

```shell
% grep fooo /var/log/auth.log

% ^o

% grep foo /var/log/auth.log
```

替换输错的部分

```shell
% ansible nginx -m command -a 'which nginx'

% !:gs/nginx/squid

% ansible squid -m command -a 'which squid'
```

####2.1.2####

重复上一条命令

```shell
% apt-get install figlet
E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)
E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?

% sudo !!
sudo apt-get install figlet
```

####2.1.3####

选取上一条命令中的第一个参数

```shell
% ls /usr/share/doc /usr/share/man

% cd !^
```

####2.1.4####

选取参数中路径的开头部分

```shell
% ls /usr/share/fonts/truetype

% cd !$:h
cd /usr/share/fonts
```

###2.2 进阶###

组合使用命令选取与参数选取

```shell
[root@localhost nginx]# ls /var/log/nginx/
access.log  access.log-20160331.gz  error.log  error.log-20160331.gz
[root@localhost nginx]# pwd
/etc/nginx
[root@localhost nginx]# cd !-2:1
cd /var/log/nginx/
[root@localhost nginx]#
```

```shell
[root@localhost nginx]# cd /var/log/nginx
[root@localhost nginx]# cd !cd:1:h
cd /var/log
```

不过`!?string`貌似无法与参数选取合用

```shell
[root@localhost log]# cd /var/log/nginx
[root@localhost nginx]# cd /etc/nginx/
[root@localhost nginx]# cd !?var:1:h
-bash: !?var:1:h: event not found
```

###2.3 ...没有高级###
