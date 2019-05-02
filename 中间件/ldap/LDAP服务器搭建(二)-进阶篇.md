# Linux平台下LDAP服务器搭建-进阶篇

## 1. 开启ldap服务器的日志输出

首先修改`/etc/openldap/sldap.conf`, 在`# database definitions`小节处添加`loglevel`字段(其实位置随便的), 如下(注意 **要用tab, 不要用空格**).

```
#######################################################################
# database definitions
#######################################################################
loglevel        1
database        bdb
suffix          "dc=generals,dc=space"
checkpoint      1024 15
rootdn          "cn=general,dc=generals,dc=space"
rootpw          123456
```

删除当前正在使用的配置文件, 并重新生成, 然后重启服务.

```shell
$ rm -rf /etc/openldap/slapd.d/*
$ slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
config file testing succeeded
$ chown -R ldap:ldap /etc/openldap/slapd.d/
$ service slapd restart
```

修改`/etc/rsyslog.conf`, `local7.* `下添加一行`local4.*`. 如下

```
local7.*                                                /var/log/boot.log
local4.*                                                /var/log/ldap.log
```

然后重启`rsyslog`服务

```shell
service rsyslog restart
```

这样当有客户端通过ldap进行认证操作时, `/var/log/ldap.log`就会记录.

## 2. 修改ldap用户密码

参考文章

[修改ldap 普通用户密码和 修改Directory Manager密码](http://xfei6868.iteye.com/blog/715792)

首先要明确一点, 即ldap服务器系统用户与ldap用户是完全不相关的, 存储位置也不一样. 只是ldap用户创建时可能需要使用系统用户`/etc/passwd`中的数据格式, ldap用户创建完成后将对应的系统用户删掉也是可以的.

因为两者并不相关, 所以不能使用`passwd 用户名`为ldap用户修改密码, 而是需要ldap本身提供的命令`ldapmodify`. 其使用方式与`ldapadd`相似.

### 2.1 修改普通用户密码

```shell
ldapmodify -x -D 'cn=general,dc=generals,dc=space' -W
Enter LDAP Password:
dn: uid=ldapuser1,ou=People,dc=generals,dc=space
changetype: modify
replace: userPassword
userPassword: 666666
<回车>
<回车>

modifying entry "uid=ldapuser1,ou=People,dc=generals,dc=space"

```

这里解释一下命令行中的参数:

- -x: 使用简单认证.

- -D: 用来绑定服务器的DN, 意思还不太明白, 总之它的取值应与`/etc/openldap/slapd.conf`中的`rootdn`字段取值相同, 可将这一大长串看作为域管理员的完整ID.

- -W: 密码输入方式, 大写的`W`会在这一行命令敲下回车后提示输入密码; 与之对应的是小写的`w`, 在其后面紧跟着密码, 如`-w 123456`. 密码依然是`/etc/openldap/slapd.conf`中`rootpw`字段的取值.

> 需要注意的是, 命令行输入LDAP密码之后是不会有任何提示的, 也就是说`dn`, `changetype`, `replace`, `userPassword`这些字段也是需要手动输入的(网上看的教程, 以为没有提示就是错误的, 纠结了很久). 而且在我实验时终端一直上卡在了`modifying entry ...`这一行, 但实际是生效了的, `Ctrl + c`退出, 密码已经被正确修改了.

另外, 可以将输入的这一段写入到一个文件里, 使用`ldapmodify`的`-f`参数读入, 可以批量修改用户密码(而且没有卡住).

```shell
vim modify.ldif

dn: uid=ldapuser1,ou=People,dc=generals,dc=space
changetype: modify
replace: userPassword
userPassword: 666666

ldapmodify -x -D 'cn=general,dc=generals,dc=space' -W -f modify.ldif
```

### 2.2 修改超级管理员密码

在同一篇文章中, 也有如何通过`ldapmodify`命令修改域管理员密码的方法. 经过试验...未成功. 报错如下

```
cat /tmp/root.ldif
dn: cn=config
changetype: modify
replace: nsslapd-rootpw
nsslapd-rootpw: 666666

ldapmodify -x -D 'cn=general,dc=generals,dc=space' -W -f /tmp/root.ldif
Enter LDAP Password:
modifying entry "cn=config"
ldap_modify: Undefined attribute type (17)
    additional info: nsslapd-rootpw: attribute type undefined
```

可能管理员的密码字段不是叫做`nsslapd-rootpw`, 暂时放弃这种方法. 最简单的一种是, 修改ldap服务器下`/etc/openldap/slapd.conf`下的`rootpw`字段的值, 然后重新生成ldap配置文件并重启`ldap`服务.

原来在`rootpw`字段下配置的是明文密码, 如果文件权限配置不发, 可能会被人窃取. 现在介绍使用`slappasswd`命令加密管理员密码的方法. 直接执行`slappasswd`, 输入目标密码A, 将默认得到`ssha`加密过的密码B.


```
slappasswd
New password:
Re-enter new password:
{SSHA}k2XOt9Uz1RaFzGJAOr7q+S7eM9NBMjCd
```

将`/etc/openldap/slapd.conf`下的`rootpw`字段设置为B, 如下.

```
rootpw      {SSHA}k2XOt9Uz1RaFzGJAOr7q+S7eM9NBMjCd
```

然后重新生成配置文件并重启`slapd`服务即可.

```shell
$ rm -rf /etc/openldap/slapd.d/*
$ slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
config file testing succeeded
$ chown -R ldap:ldap /etc/openldap/slapd.d/
$ service slapd restart
```

## 3. sudo权限配置

参考文章

[开源跳板机(堡垒机)JumpServer v2.0.0 部署篇](http://laoguang.blog.51cto.com/6013350/1636273)

[openldap线上实战(账户管理+自动创建家目录+sudo权限管理)](http://blog.chinaunix.net/uid-9532975-id-5711854.html)

[OpenLDAP--使用sudo进行权限分配](http://opjasee.com/2014/03/28/openldap-use-sudo.html)

我们之前的配置是得到可以登录帐号不是保存在本机上的ldap客户机, 但他们都是普通用户的权限. 当我们不想要分配给用户root权限, 却又希望用户可以拥有部分`sudo`权力(比如安装软件包)时, 就需要让ldap接管客户机的`sudo`操作了.

### 3.1 服务端

> Schema是LDAP的一个重要组成部分, 类似于数据库的模式定义, LDAP的Schema定义了LDAP目录所应遵循的结构和规则. 比如一个 objectclass会有哪些属性, 这些属性又是什么结构等等. schema给LDAP服务器提供了LDAP目录中类别, 属性等信息的识别方式, 让这些可以被LDAP服务器识别.

OpenLDAP的默认schema中是不包含sudo所需要的数据结构的，需要自行导入。不过正好, sudo本身提供了对OpenLDAP的schema支持, 我们将其拷贝至ldap的schema目录即可(注意不同sudo的版本, 这里是CentOS6, sudo-1.8.6).

```shell
cp /usr/share/doc/sudo-1.8.6p3/schema.OpenLDAP /etc/openldap/schema/sudo.schema
```

然后将其引入到`slapd.conf`文件中(这里面的`include`语句有很多, 照做就是了).

```
include         /etc/openldap/schema/sudo.schema
```

现在重新生成配置文件, 还是老方法.

```shell
$ rm -rf /etc/openldap/slapd.d/*
$ slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
$ chown -R ldap:ldap /etc/openldap/slapd.d/*
$ service slapd restart
```

现在有了`sudo.schema`, OpenLDAP可以接受`sudo`类型的内容了, 现在我们要在其中创建这样的内容, 即创建`Sudoers`子树, 并在其中增加成员. 导入的内容需要具有一定格式, 参见如下内容.

```
$ cat sudo.ldif
dn: ou=Sudoers,dc=generals,dc=space
objectClass: top
objectClass: organizationalUnit
ou: Sudoers

dn: cn=defaults,ou=Sudoers,dc=generals,dc=space
objectClass: top
objectClass: sudoRole
cn: defaults
sudoOption: !visiblepw
sudoOption: always_set_home
sudoOption: env_reset
sudoOption: requiretty

dn: cn=ldapuser1,ou=Sudoers,dc=generals,dc=space
objectClass: top
objectClass: sudoRole
cn: ldapuser1
sudoCommand: ALL
sudoHost: ALL
sudoOption: !authenticate
sudoRunAsUser: ALL
sudoUser: ldapuser1

$ ldapadd -x -W -D 'cn=general,dc=generals,dc=space' -f sudo.ldif
```

OK, 关于`sudo.ldif`中的内容, 前两块应该是导入`Sudoers`组, 之后是将可以拥有`sudo`权限的用户`ldapuser1`导入到这个组中(注意起码这个用户得是普通用户, 不然即使有`sudo`权限, 但连`ssh`都连不上就尴尬了.)

解释一下第三块中的各字段含义:

- cn: ldapuser1 #ou=People 下的ldapuser1用户 密码是创建用户时的最初始密码或通过`ldapmodify`修改过的密码.

- sudoCommand: ALL # 允许执行的命令,

- sudoHost: ALL #允许登录的Host, 可以参考`/etc/sudoers`中的`root`配置.

- sudoOption: !authenticate # 是否需要输入密码, 可以参考`/etc/sudoers`中的`root`配置.

- sudoRunAsUser: ALL #以哪个用户执行

### 3.2 客户端

客户端需要配置`sudo`操作转而请求`ldap`的许可.

sudo版本不同使用的配置文件可能也有所不同(有的是`sudo-ldap.conf`而有的是`ldap.conf`)，使用`sudo -V | grep 'ldap.conf'` 查看.

```shell
sudo -V | grep 'ldap.conf'
...
ldap.conf path: /etc/sudo-ldap.conf
```

现在, 在`/etc/sudo-ldap.conf`文件中添加(其实也不是添加, 只是这些字段默认被注释掉, 修改成自己的信息即可)

```
$ vim /etc/sudo-ldap.conf
uri ldap://192.168.20.130
sudoers_base ou=Sudoers,dc=generals,dc=space
```

然后修改`/etc/nsswitch`文件

```
vim /etc/nsswitch
Sudoers: files ldap
```

不用重启`nslcd`, 也不用重启`sshd`, 完工.

### 3.3 测试

执行`sudo su`, 如果不再提示输入密码就切换到`root`身份, 就说明成功.

## 4. 常规命令

在第一篇中试验过添加成员与将成员添加至组, 现在介绍命令行的查询与删除.

### 4.1 查询

```shell
ldapsearch -x -b 'ou=Group,dc=generals,dc=space'
```

`-x`是使用简单认证(具体作用我暂也不清楚, 只知道先这么用).

`-b`指定的是从哪个节点开始查询. 比如指定为`dc=generals,dc=space`将会查询整个ldap目录所有的对象, 包括组与成员; 示例中指定为`ou=Group,dc=generals,dc=space`, 那么就只会查询到`Group`这个普通组中的内容, `Sudoers`这个与`Group`平级中的内容就不会出现在显示结果中.

### 4.2 删除

```shell
ldapsearch -x -W -D 'cn=general,dc=generals,dc=space' 'cn=ldapuser1,ou=Sudoers,dc=generals,dc=space'
```

这个就更简单了, `-D`指定管理员完整ID(姑且先这么叫), 之后指定将要被删除的用户完整ID即可. 示例中将`ldapuser1`从`Sudoers`组中除去了. 被删除用户的完整ID可以用上面的`ldapsearch`命令查看.

另外, 如果要删除整个组, 可以使用`-r`选项, 否则只能先将组内成员删除才行.

```shell
$ ldapsearch -x -W -D 'cn=general,dc=generals,dc=space' 'ou=Sudoers,dc=generals,dc=space'
Enter LDAP Password:
ldap_delete: Operation not allowed on non-leaf (66)
    additional info: subordinate objects must be deleted first

$ ldapsearch -x -W -D 'cn=general,dc=generals,dc=space' -r 'ou=Sudoers,dc=generals,dc=space'
Enter LDAP Password:

```

## 5. ldap图形管理

参考文章

[phpLDAPadmin 安装配置讲解，通过 Web 端来管理您的 LDAP 服务器](http://zzjnet.blog.51cto.com/323001/127853)

windows下有名为`LdapBrowser282`的软件, 这里介绍的是另一种`phpLDAPadmin`. 如名称所示, 这是一个php网页应用, 需要配置Apache与PHP. CentOS6下有这个软件包(是全套哦), 不过没有在官方源里面, 而是在`epel`源中, 如果没有, 需要首先安装这个yum源.

系统版本: CentOS6.5

```shell
yum install phpldapadmin
```

安装完成后需要自行配置, 如下

首先是`conf/httpd.conf`

```
vim /etc/httpd/conf/httpd.conf

...
DocumentRoot "/usr/share/phpldapadmin"
...
<Directory "/usr/share/phpldapadmin">
...
```

然后是`conf.d/phpldapadmin.conf`

```
#
#  Web-based tool for managing LDAP servers
#

Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs

<Directory /usr/share/phpldapadmin/htdocs>
  Order Deny,Allow
  Deny from all
  Allow from 127.0.0.1
  Allow from ::1
  ## 默认是Deny from all, 这样只有本机才可以访问
  ## 这里自定义可以访问的网段, 否则会出现403 Forbidden
  Allow from 172.32.100.0/255.255.255.0
</Directory>

```

另外, 注意赋予`/usr/share/phpldapadmin`下所有文件以755的权限, 并且最好将该目录属主更改为apache进程的所有者

```shell
chmod -R 755 /usr/share/phpldapadmin
chown -R apache:apache /usr/share/phpldapadmin
```

现在访问ldap服务器已经可以出现登录界面了, 但要登录并管理ldap, 还需要接着对`phpldapadmin`进行配置, 主要是`phpldapadmin/config/config.php`. 将这些内容的注释块解开并设置为你自己的.

```php
/*********************************************
 * Define your LDAP servers in this section  *
 *********************************************/
$servers->setValue('server','name','LDAP域管理器');
$servers->setValue('server','host','127.0.0.1');
$servers->setValue('server','port',389);

// LDAP服务器的baseDN, 注意与/etc/openldap/slapd.conf中匹配即可
$servers->setValue('server','base',array('dc=genreals,dc=space'));
// 这种验证方式要求输入管理员完整的DN作为登录名(如cn=general,dc=generals,dc=space)
$servers->setValue('login','auth_type','session');
$servers->setValue('login','attr','dn');
$servers->setValue('login','base',array('dc=jumpserver,dc=org'));

$servers->setValue('server','read_only',false);
$servers->setValue('appearance','show_create',true);
```

这样, 就可以以`cn=general,dc=generals,dc=space`为用户名, 密码还是在`slapd.conf`中的密码进行登录了.

### 遇见问题

登录网页端后, 左侧显示的目录树中没有出现目标结构, 只有一句`This base cannot be created with PLA.`

意思是PLA没有办法在此baseDN上进行操作.

参考[这里](http://stackoverflow.com/questions/13921030/phpldapadmin-does-not-work-for-an-unknown-reason)的解答, 检查`config.php`中这两句是否正确.

```php
$servers->setValue('server','base',array('dc=generals,dc=space'));
$servers->setValue('login','bind_id','cn=admin,dc=generals,dc=space');
```

## 6. 加密密码

ldap服务器可以使用 `{加密方式}加密后的字符串`取代明文密码. 可以配置在`/etc/openldap/slpad.conf`中的`root_pw`或新增/修改People对象的`userPassword`字段的值. 借助`ldap`自带的`slappasswd`命令.

```
$ slappasswd -h {加密算法}
New password: 
Re-enter new password:
将返回对应的 '{加密方式}加密后的字符串'
```

其中, 可用的加密算法有 `SSHA(缺省值)`, `SMD5`, `MD5`和`SHA`.

示例

```
$ slappasswd -h {sha}
New password: 
Re-enter new password:
{SHA}PU8r8H3BvjiyDNbkaUmhBx+dDj0=
```

## FAQ

直接拷贝文章中的ldif内容要注意, 块与块之间用空行隔开, 但同个块内的每一行之间不能不能有空行, 否则可能报如下错误.

```
adding new entry "ou=xxx,dc=yyy,dc=zzz"
ldap_add: Protocol error (2)
	additional info: no attributes provided

```

这说明导入的ldif文件格式有错误.
