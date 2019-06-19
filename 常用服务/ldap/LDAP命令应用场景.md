# LDAP 命令应用场景及使用方法

## 1. 查询

参考文章

[LDAP Search Filters](https://www.centos.org/docs/5/html/CDS/ag/8.0/Finding_Directory_Entries-LDAP_Search_Filters.html)

```
ldapsearch [options] [filter [attributes...]]
```

### 1.1 普通查询

```
ldapsearch -x -b 'ou=Group,dc=generals,dc=space'
```

`-x`的作用暂不追究, `-b` 指定从目录树中哪个节点开始查询(可能是树的根节点, 也可能是一棵子树).

`-b`的值可以是`dc=generals,dc=space`, 即base_dn, 将从目录树的根节点开始查询. 示例中指定了`ou=Group`前缀, 表示查询此base_dn所代表的树中`Group`子树中的所有节点.

### 1.2 过滤查询

filter过滤语法及示例

```
## 1. 指定目标用户ID/分组类型(分组类型包括People, Group, Sudoers)
$ ldapsearch -x -b 'dc=jumpserver,dc=org' 'cn=ldapuser1'
$ ldapsearch -x -b 'dc=jumpserver,dc=org' 'ou=Sudoers'
## 注意: 一个过滤项的标准格式是使用()包裹起来, 所以上述项也可以等于
$ ldapsearch -x -b 'dc=jumpserver,dc=org' '(cn=ldapuser1)'
$ ldapsearch -x -b 'dc=jumpserver,dc=org' '(ou=Sudoers)'
## 以上都是精确匹配, 还可以使用*通配符进行部分匹配
$ ldapsearch -x -b 'dc=jumpserver,dc=org' '(cn=ldapuser*)'
## 还有数值比较操作符>=, <=, 可以用于uidNumber, gidNumber的过滤
## ~=模糊匹配(查询关键字相差的地方不多的话可以匹配得到), 不过感觉不太好用, 这里不举例说明了

## 2. 组合过滤.
## 注意布尔运算符的位置...与普通的操作不太一样, 复杂一点的过滤条件需要好好组织一下括号的排列
## 可用的布尔运算符有&, |, !
$ ldapsearch -x -b 'dc=jumpserver,dc=org' '(|(ou=Sudoers)(ou=Group))'
```

## 2. 新建

新建的目标, 可以说是一个对象, 条目, 或者干脆是目录树中的一个节点. 总之是拥有一系列属性的一个实例.

### 2.1 新建People对象

我们知道, 一个对象总是拥有许多属性, 新建一个新的对象自然有一些属性是必须明确指定, 而另一些则可以有默认值.

使用`ldapsearch -x -b 'ou=People,dc=generals,dc=space'`命令可以查看ldap服务器中已经存在的People对象属性(如之前使用`migrationtools`创建的ldap用户).

经过实验, 添加一个对象所需的最小属性为

```
## 注意管理员cn, 与两个dc所代表的base_dn要根据自己实际情况修改
$ ldapadd -x -W -D 'cn=general,dc=generals,dc=space'
dn: uid=ldapuser,ou=People,dc=generals,dc=space
objectClass: account
```

这样, 一个新的People对象就可以成功创建了. 但是它什么都不能做, 不能在ldap客户端使用`su`切换身份, 也不能在其他主机上使用ssh登录ldap客户端.

------

指定如下属性可以实现在ldap客户端使用`su`切换身份. 首先应该指定`loginShell`字段, 其依赖于`objectClass:postAccount`. 而`postAccount`又需要指定`udiNumber`, `gitNumber`, `cn`与`homeDirectory`字段. 

```
$ ldapadd -x -W -D 'cn=general,dc=generals,dc=space'
dn: uid=ldapuser,ou=People,dc=generals,dc=space
uidNumber: 5003
gidNumber: 5003
cn: ldapuser
objectClass: account
objectClass: posixAccount
loginShell: /bin/bash
homeDirectory: /home/ldapuser
```

但是由于没有明确指定`userPassword`字段, 所以这个示例没有办法让其他主机使用`ssh`登录ldap客户端. 

另外, ldap服务器中默认使用uid字段唯一确定一个对象, 所以只要`uid`不与其他对象冲突即可, `uidNumber`, `gidNumber`与`cn`的值可以重复.

------

然后, 要让ldap客户端可以正常被其他机器通过ssh访问, 只要设置`objectClass: shadowAccount`与`userPassword`并指定相应的密码即可.

```
$ ldapadd -x -W -D 'cn=general,dc=generals,dc=space'
dn: uid=ldapuser,ou=People,dc=generals,dc=space
uidNumber: 5003
gidNumber: 5003
cn: ldapuser
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
loginShell: /bin/bash
homeDirectory: /home/ldapuser
userPassword: 111111
```

这里再说一点, 上面示例中, `userPassword`的值为明码, 其实也可以使用`{加密方式}加密后的密码`的形式, 类似于ldap服务端`/etc/slpad.conf`中`root_pw`的设置.

### 2.1 新建Group对象



### 2.1 新建ou单元