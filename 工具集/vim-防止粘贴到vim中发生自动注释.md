# vim-防止粘贴到vim中发生自动注释

参考

1. [vi换行自动注释](http://bbs.csdn.net/topics/320134361)

copy代码到vim中时, 如果某一行使用了注释, 那其之后的所有行都被自动添加了注释.

解决办法:

`set formatoptions=ql`, 然后再copy到vim中, 就不会出现这种情况了.

如果要写到`.vimrc`文件中, 除了这句以外, 还需要再加上`set paste`, 否则不生效.
