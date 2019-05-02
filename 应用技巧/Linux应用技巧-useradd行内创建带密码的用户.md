# Linux应用技巧-useradd行内创建带密码的用户

参考文章

1. [linux下创建带密码的用户](http://blog.csdn.net/dliyuedong/article/details/24228599)

主要是为了在脚本中完成创建用户的操作, 同时不需要进入交互模式去为新用户设置密码.

`useradd`命令有一个`-p`选项, 可在创建用户的同时为其指定密码. 但这个密码是经过`crypt`加密过的, 即必须是密文(验证时使用对应的明文). `man`手册中对其的介绍如下

```
    -p, --password PASSWORD
        The encrypted password, as returned by crypt(3). The default is to disable the password.

        Note: This option is not recommended because the password (or encrypted password) will be visible by users listing the processes.

        You should make sure the password respects the system's password policy.
```

需要注意的是, `crypt`并不是一个命令, 而是一个头文件(使用`whereis crypt`可以查看到相关信息), 它在`openssl-devel`包中. 我们并没有办法使用它.

替代方法是使用`openssl`命令. `openssl`有一个子命令`passwd`用来生成密码. 它的相关帮助信息如下

```
$ openssl passwd --help
Usage: passwd [options] [passwords]
where options are
-crypt             standard Unix password algorithm (default)
-1                 MD5-based password algorithm
-apr1              MD5-based password algorithm, Apache variant
-salt string       use provided salt
-in file           read passwords from file
-stdin             read passwords from stdin
-noverify          never verify when reading password from terminal
-quiet             no warnings
-table             format output as table
-reverse           switch table columns
```

其中`-crypt`, `-1`与`-apr1`三者是并列关系, 如果不指定, 则默认为`-crypt`的加密方式, 这也是系统密码的默认算法. 

我们可以使用如下方法获得加密后的密码

```
$ openssl passwd 123456
VGmG1B363td7o
```

然后创建目标用户, 如`general`

```
$ useradd general -p VGmG1B363td7o
```

之后就可以使用`general`及其密码`123456`进行登录或切换用户等操作了.

更为简便一点的方式

```
$ useradd general -p $(openssl passwd 123456)
```

除了这种方式, 也可以交互式从终端输入密码, 或是从文件读取然后批量生成.

```
$ openssl passwd
Password: <=输入123456
Verifying - Password: <=输入123456
hE/MhvW1qosEs
```

**注意: 虽然明文都是123456, 但加密后的密文并不相同. 即使如此, 创建用户时指定这些密文为密码, 其明文都会是123456, 不必担心**

从文件读取

```
$ cat passwd
123456
123456
## 这里得到的密码依然不一样哦
$ openssl passwd -in ./passwd
mEX6A8pyoI2do
UtFubbGdts3fg
```
