# Shell脚本-写出健壮的Bash脚本

译者: **richard_ma** 原作者: **David Pashley**

>许多人用shell脚本完成一些简单任务，而且变成了他们生命的一部分。不幸的是，shell脚本在运行异常时会受到非常大的影响。在写脚本时将这类问题最小化是十分必要的。本文中我将介绍一些让bash脚本变得健壮的技术。

## 1. 使用`set -u`

你因为没有对变量初始化而使脚本崩溃过多少次？对于我来说，很多次。

```shell
chroot=$1
...
rm -rf $chroot/usr/share/doc
```

如果上面的代码你没有给参数就运行，你不会仅仅删除掉chroot中的文档，而是将系统的所有文档都删除。那你应该做些什么呢？好在bash提供了`set -u`，当你使用未初始化的变量时，让bash自动退出。你也可以使用可读性更强一点的`set -o nounset`。

```shell
david% bash /tmp/shrink-chroot.sh
$chroot=
david% bash -u /tmp/shrink-chroot.sh
/tmp/shrink-chroot.sh: line 3: $1: unbound variable
david%
```

## 2. 使用`set -e`

你写的每一个脚本的开始都应该包含`set -e`。这告诉bash一但有任何一个语句返回非真的值，则退出bash。使用**-e**的好处是避免错误滚雪球般的变成严重错误，能尽早的捕获错误。更加可读的版本：`set -o errexit`.

使用 **`-e`** 把你从检查错误中解放出来。如果你忘记了检查，bash会替你做这件事。不过你也没有办法使用**`$?`**来获取命令执行状态了，因为bash无法获得任何非0的返回值。你可以使用另一种结构：

```shell
command
if [ "$?"-ne 0]; then echo "command failed"; exit 1; fi
```

可以替换成：

```shell
command || { echo "command failed"; exit 1; }
```

或者使用：

```shell
if ! command; then echo "command failed"; exit 1; fi
```

如果你必须使用返回非0值的命令，或者你对返回值并不感兴趣呢？你可以使用 `command || true `，或者你有一段很长的代码，你可以暂时关闭错误检查功能，不过我建议你谨慎使用。

```shell
set +e
command1
command2
set -e
```

相关文档指出，bash默认返回管道中最后一个命令的值，也许是你不想要的那个。比如执行 false | true 将会被认为命令成功执行。如果你想让这样的命令被认为是执行失败，可以使用 `set -o pipefail`

## 3. 程序防御 - 考虑意料之外的事

你的脚本也许会被放到“意外”的账户下运行，像缺少文件或者目录没有被创建等情况。你可以做一些预防这些错误事情。比如，当你创建一个目录后，如果父目录不存在，`mkdir` 命令会返回一个错误。如果你创建目录时给`mkdir`命令加上`-p`选项，它会在创建需要的目录前，把需要的父目录创建出来。另一个例子是 `rm` 命令。如果你要删除一个不存在的文件，它会“吐槽”并且你的脚本会停止工作。（因为你使用了`-e`选项，对吧？）你可以使用`-f`选项来解决这个问题，在文件不存在的时候让脚本继续工作。

有些人从在文件名或者命令行参数中使用空格，你需要在编写脚本时时刻记得这件事。你需要时刻记得用引号包围变量。

```shell
if [ $filename = "foo" ];
...
fi
```

当$filename变量包含空格时就会挂掉。可以这样解决：

```shell
if [ "$filename" = "foo" ];
...
fi
```

使用`$@`变量时，你也需要使用引号，因为空格隔开的两个参数会被解释成两个独立的部分。

```shell
david% foo() { for i in $@; do echo $i; done ;}
foo bar "baz quux"
bar
baz
quux

david% foo() { for i in "$@"; do echo $i; done ;}
foo bar "baz quux"
bar
baz quux
```

我没有想到任何不能使用`$@`的时候，所以当你有疑问的时候，使用引号就没有错误。如果你同时使用find和xargs，你应该使用 `-print0` 来让字符分割文件名，而不是换行符分割。

```shell
david% touch "foo bar"
david% find | xargs ls
ls: ./foo: No such file or directory
ls: bar: No such file or directory
david% find -print0 | xargs -0 ls
./foo bar
```

