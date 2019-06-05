# Shell-移除^M字符

参考文章

1. [Linux下去掉^M的四种方法](https://blog.csdn.net/qq_38500662/article/details/80733238)

> `^M`一般是windows下的`\r`在linux系统下的显示字符. 在vim中, `^M`的输入方法为`ctrl + v`, 然后再`ctrl + m`.

四种方法移除`^M`字符串. 

1. `dos2unix 目标文件名`

不过`dos2unix`需要单独安装.

2. `sed -i 's/^M//g' 目标文件名`

这是直接把`^M`当作独立的可见字符来处理了.

3. 用vi

命令模式下输入`:1,$ s/^M//g`

4. `cat 目标文件名 | tr -d '/r' > newfile`

> `^M`在bash中不像在vim里那样可见, 可用`/r`代替.

优点是可以在行内处理, 然后直接输出.