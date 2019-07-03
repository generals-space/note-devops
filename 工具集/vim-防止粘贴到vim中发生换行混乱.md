# vim-防止粘贴到vim中发生换行混乱

参考文章

[解决粘贴到终端 Vim 缩进错乱](http://ruby-china.org/topics/13307)

[Vim 复制粘贴探秘](http://www.cnblogs.com/end/archive/2012/06/01/2531147.html)

以如下代码为例

```html
<!DOCTYPE>
<html>
        <head>
        </head>

        <body>
        </body>
</html>
```

在开启了`autoindent`选项的vim中(开启`autoindent`会在编辑模式中自动缩进)粘贴存在缩进的代码会变的很混乱.

```
<!DOCTYPE>
<html>
        <head>
                </head>

                        <body>
                                </body>
                                </html>
```

原因是在vim中没有相应的程序来处理这个从其他应用复制粘贴的过程，所以vim通过插入键盘输入的buffer来模拟这个粘贴的过程，这个时候vim仍然以为这是用户输入的。

问题就是出在这：**当上一行结束，光标进入下一行时Vim会自动以上一行的的缩进为初始位置。这样就会破坏原始文件的缩进**。

解释方法就是, 开启vim的"粘贴"模式, 将拷贝的代码原样粘贴.

在vim中执行`set paste`. 然后在进入编辑模式时, 会看到vim左下角的标记为`-- INSERT (paste) --`, 此时执行粘贴操作就不会再出现换行混乱的情况.

粘贴完毕后需要再执行`set nopaste`, 不然自动缩进选项就无效了.

OK, 其实还有`pastetoggle`选项, 可以方便的在两种状态之间转换, 当然, 每次粘贴都要输入命令实在太麻烦, 我们可以绑定vim的一个快捷键. 如下, `F3`可以切换`paste`状态.

```
set pastetoggle=<F3>
```
