# tar无法解压.tar.gz后缀的压缩文件

```
$ tar -zxf ./access.tar.gz 
tar: This does not look like a tar archive
tar: Skipping to next header
tar: Exiting with failure status due to previous errors
```

解决办法: 

单独使用`gzip`与`tar`命令进行解压与解包

```
$ gzip -d access.tar.gz
$ tar -xf access.tar
```
