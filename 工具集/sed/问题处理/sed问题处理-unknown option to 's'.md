# sed问题处理-unknown option to "s"

参考文章

1. [用变量替换指定的字符串，sed: -e 表达式 #1, 字符 29: “s”的未知选项](https://www.cnblogs.com/lemon-le/p/6020695.html)
2. [sed: -e expression #1, unknown option to `s'解决办法](https://www.cnblogs.com/tuhooo/p/7677488.html)
3. [sed fails with “unknown option to `s'” error](https://stackoverflow.com/questions/9366816/sed-fails-with-unknown-option-to-s-error)
    - 采纳的回答中给出了更换分隔符的原因.

## 场景描述

在查看kuber存储在etcd中的信息时, 希望得到某一目录下的子目录名称, 类似v2接口中的ls命令. 输出如下

```console
$ etcdctl get --prefix --keys-only /registry/
/registry/services/endpoints/etcd/etcd-operator
/registry/services/specs/kube-system/kube-dns
/registry/storageclasses/local-path
...
```

## 实验操作

我想得到`/registry`目录下所有子目录名称, 如`services`, `storageclasses`...等. 使用`sed`命令完成这个功能

```console
$ etcdctl get --prefix --keys-only /registry | sed -n "s/\/registry\/\([^\/]*\).*/\1/p"
services
services
storageclasses
```

之后当然可以使用`uniq`等工具去重, 但我希望能把上面的命令抽象成一个函数, 目标目录`/registry`需要是一个变量才行.

但是出现了如下问题.

```console
$ dir=/registry
$ etcdctl get --prefix --keys-only $dir | sed -n "s/$dir\/\([^\/]*\).*/\1/p"
sed: -e expression #1, char 27: unknown option to `s'
```

到网上查了查, 发现将分隔符`/`修改为`#`或`|`后的确可行.

```console
$ ## etcdctl get --prefix --keys-only $dir | sed -n "s#$dir\/\([^\/]*\).*#\1#p"
$ etcdctl get --prefix --keys-only $dir | sed -n "s|$dir\/\([^\/]*\).*|\1|p"
services
services
storageclasses
```

有文章说除了`#`, `|`, 还有`!`也可以实现, 我试了试, 不行.

```
$ etcdctl get --prefix --keys-only $dir | sed -n "s!$dir\/\([^\/]*\).*!\1!p"
-bash: !\1!p: event not found
```

## 解决方法

但是只有参考文章3给出了还算靠谱的解释: 

出现这个问题的原因是, `sed`命令的pattern中字符串中存在变量, 且变量中包含`/`.

`sed`可以用任何字符作为分隔符, 所以随便更换一个pattern变量中不存在的字符即可.
