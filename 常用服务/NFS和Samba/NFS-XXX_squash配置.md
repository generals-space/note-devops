# NFS-XXX_squash配置

参考文章

1. [NFS服务基本配置及使用](https://www.cnblogs.com/lykyl/archive/2013/06/14/3136921.html)

2. [root_squash关于NFS参数说明](http://www.360doc.com/content/14/0527/00/17617523_381280598.shtml)

NFS服务在安装时就拥有了一个名为`nfsnobody`的系统用户和用户组, `XXX_squash`是4个配置项应该是基于为该目录设置了`rw`权限的情况.

这4个选项实际是两对选项:

`all_squash`与`no_all_squash`取一, 默认为`no_all_squash`; 

`root_squash`与`no_root_squash`取一, 默认为`root_squash`.

- `no_all_squash`: 默认, 客户端挂载后, 访问用户先与服务端用户匹配, 匹配失败后再映射为匿名用户或用户组(`nfsnobody`); 
- `all_squash`: 所有访问用户都映射为匿名用户或用户组.

- `root_squash`: 默认, 客户端挂载后, 访问的root用户及所属组全部映射为服务端的匿名用户或用户组(`nfsnobody`);
- `no_root_squash`: 来访的root用户保持root帐号权限.

保持权限, 映射(或者说压缩)权限是什么意思?

比如NFS服务端共享`/mnt/medianfs`, 权限设置为`rw,no_all_squash,root_squash`, 客户端挂载后, 在该目录下创建新文件, 文件属主将为`nfsnobody`, 需要服务端`nfsnobody`拥有该共享目录的写入权限, 所以该共享目录在服务端的属主也应该是`nfsnobody`.

ok, 懂了这两对配置, 再来看看`anonuid`和`anongid`.

我们知道`no_all_squash`访问用户会先与服务端用户匹配, 匹配失败会映射为`nfsnobody`, 如果不希望使用这个默认值, 可以自行指定一个uid.