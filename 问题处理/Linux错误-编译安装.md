#linux常用编译安装时的各种错误#

## 1. apache##

```shell
configure: error: Size of "void *" is less than size of "long"
```

解决方式有两种

- 1.移除--with-pcre=/xxx/xxx/pcre选项

- 2.增加 ap_cv_void_ptr_lt_long=no

当时用的第一种, 系统中原来有pcre包, pcre-devel安装之后又卸载了, 然后源码装的pcre. 可能这样导致与系统本身的pcre冲突, 直接使用系统中的pcre即可

##杂项##

## 

```
Package libzmq was not found in the pkg-config search path
```

解决方法

```
$ export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```