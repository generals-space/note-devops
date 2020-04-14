# Linux cp错误-not writing through dangling symlink

原因分析: cp命令的目标文件已经存在, 而且是一个软链接. 如果要cp的话, 可以先删除这个软链接, **不过要确定这个链接真的没用了才好**.

比如

```shell
$ ln -s /random/file f
$ cp -f a f
cp: not writing through dangling symlink ‘f’
$ cp --remove-destination a f
$ diff a f && echo yes
yes
```
