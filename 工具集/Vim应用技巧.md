# Vim 应用技巧

## 1. 变量设置详解

### 1.1 取消自动注释

参考

[vi换行自动注释](http://bbs.csdn.net/topics/320134361)

copy代码到vim中时, 如果某一行使用了注释, 那其之后的所有行都被自动添加了注释.

解决办法:

`set formatoptions=ql`, 然后再copy到vim中, 就不会出现这种情况了.

如果要写到`.vimrc`文件中, 除了这句以外, 还需要再加上`set paste`, 否则不生效.

### 1.2 防止粘贴到vim中换行混乱

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

#### 1.2.1 深究



## 2. 快捷键应用及配置

### 2.1 缩进

#### 2.1.1 单行

在当前行按下`>>`或`<<`可以增加或减少缩进.

另外, 当前行按下`==`可以将内容移至行首.

#### 2.1.2 多行

按`v`进入visual状态，选择多行，用`>`或`<`增加或减少缩进.

或者`n>`/`n<`可以对以下`n`行增加或减少缩进. 

`>nj`/`<nj`可以达到同样的效果, 而`>nk`/`<nk`则可以对当前行以上`n`行增加或减少缩进.

ok, 上面的`j`/`k`可以用`G`/`gg`替换, 就是说, 从当前行到最后一行/第一行的内容都可以缩进, `>G`/`>gg`.

按`v`选中多行按`==`可以将选中行内容都移至行首, 当然也可以`n==`, 将当前行下`n`行的内容移至行首.

不过可惜的是, 没有办法进行多行连续缩进...

## 3. dos与unix格式切换

```
:set fileformat=unix
:set fileformat=dos
```

## 4. 设置tab为空格

参考文章

[vim tab设置为4个空格](http://blog.csdn.net/jiang1013nan/article/details/6298727)

在.vimrc中添加以下代码后，重启vim即可实现按TAB产生4个空格：

```
set ts=4  (注：ts是tabstop的缩写，设TAB宽4个空格)
set expandtab
```

对于已保存的文件，可以使用下面的方法进行空格和TAB的替换：
TAB替换为空格：
```
:set ts=4
:set expandtab
:%retab!
```

空格替换为TAB：

```
:set ts=4
:set noexpandtab
:%retab!
```

加`!`是用于处理非空白字符之后的TAB，即所有的TAB，若不加`!`，则只处理行首的TAB。