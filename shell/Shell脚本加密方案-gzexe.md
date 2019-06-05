# Shell脚本加密方案-gzexe

参考文章

1. [SHELL脚本加密](http://www.bubuko.com/infodetail-2019877.html)

之前一直不知道像Shell这样的纯文本文件也可以加密的, 而且不像js那样代码压缩混淆, 只是结构, 变量名称什么的变了, 本质还是文本文件. Shell脚本加密后生成的文本无法再通过文本方式阅读(只能看到乱码), 但是不影响执行(包括传入参数与输出).

其中一种加密方案是使用`gzexe`工具. `gzexe`在一般的linux发行版中都有安装, 它的使用方法简单, 不但加密, 同时压缩文件.

加密一个文件只需要执行`gzexe 目标文件`即可, 在当前目录会生成一个以`~`结尾的与目标文件同名的文件. 如下

```
$ ls
test.sh
$ gzexe test.sh 
test.sh:	 51.8%
$ ll
total 24
-rw-r--r-- 1 root root 1629 Jun 19 22:08 test.sh
-rw-r--r-- 1 root root 1652 Jun 15 19:58 test.sh~
```

现在, 原来的`test.sh`已经是加密过的文件了, `test.sh~`才是原文件, 而前者拥有与原文件完全一致的功能.

------

`gzexe`加密方式不是非常保险的方法，但是能够满足一般的加密用途，可以隐蔽脚本中的密码等信息。你或许有机会接触到使用`gzexe`加密的脚本, 它们几乎拥有相同的特征, 打开上面加密后的`test.sh`, 你可以看到如下内容.

```bash
#!/bin/sh
skip=44

tab='   '
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -dt`
else
  gztmpdir=/tmp/gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `echo X | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  echo >&2 "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
^_<8b>^H^HXvBY^B^Cpython2.7.sh^@­TmOÓP^Tþ¾_qd^D^RCoÇ<8c><88>K ^R^E%^QÄ^Eü´/¥»<83><86>®­m'<8c>OC$°^@^B   
  Â^R^T<82><89>^L^S<8c>^A&îÏì¶Û¿ðÞÞ²^A^Y<89>D<9b>të=ç9ç<Ï=÷<9e>`^P^FÒö¨®A^X=^@²}æîf*k92½^T^A<92>Ï<96>?Í8gËîÎ<94>ûk½|´ÒâÛ^LÅh<81>rþ·{<9e>ç`^F:Ì^F<82>A(<9d>^WÝÕ^CgýÔ9^<8b>@\<97>Ç°      Ã)E<8d><83><90>ð×     EÅÎúl©ð<93>,/<82>`<83><9f>¤jzr^Mæd3$wànåÉù^Z+^Rí~9Ô^[í<8e>@%<97>)ïO<91>ý·¥<93>y^N­d6ËÅÙr1ç^^ÌÇõqMÕ 
¥x©ð<85>Ì.<91>ï+¼<8e>ûõ¬òá^GYÜ¡Di6<9a>¯^U<81>áí^B^WK^Vf¸=<8c>`^DÛ^B<95><8b><8c>4ÏÏ^]÷h^@5Êº<96>ðÍ<81><9e>è<8b>>_^_²ÆÒBR^_V( ^Y¹^_
<85>D^Yk¶nEÚP^H<85>¼^Tÿò°-à<95>¸ ª<99>Jáý`>2·E
gåÌL©¸ëL^]^Eúºzû^GéÛ^]¥r4lJ*4ø^_^V²^LIÆ<8f>F<92><92>¢2º^M,<81>ûþ<88>ìM<93>¥<8d>ÊìR^Kk)¯Fò§äã<81>³
zä,L<95>N^N©ò@wÿ+xÞÕÿ^T^^£¡Á^^¡ý¿hã'2^P^]ê<87>t*   B^Z^TÍ²%Uõ»$Äñ^[¬<82>n`Í²T^?e½V^U^[û<8b>X^@èÓÔäÅË*<96>4 á^F9eª0jÛFD^T[^_<86>Qk[;}ÛP8^\^R-=a<8f>K&^Vy^]<91>^S^QèÕ@­ad<8f>L<82> <83>h'<8d>:<9e>jI9îAØ§-<99> LL
N$^@ýEÀUHÍ<8d>DvÌ<94><91><94><89>A^P^L^S'<94><89>^N1e<99>¢ªË<92>êse×·^Z<92><94>Æpõÿbïª^<93>n©<99>¨Són^M<83>åQ^]<9a>^Gº^F<9f>u4²ßH½<82>â°¢5Cg'<88>Ø<96>EÃÔÙ<8d>½<9e>ÃÒS¦<8c>¯@x<8c>©ë¶<88><86>%kÔ<94>^CÞè(æ<9d>ÕS÷¸à^V¶+<85><8d>rþ3¯äfç<9c>Ü·^Vp¶<8a>Îâ^^í(<9f>1îæ»Ë~¯¹L^ZUÆ¸Rn>SÆEÕ@°à&^Q^WÀë<81>U)^V¦ãK¡bÄX0v'Æp1^F<8c>ùÈÆ^[ìaÔ&6×ÒRî<9e>Ò<9b>§è­<8f>hm>UÏæ%S½Cék«<87>º|2êf¹^E±<8b>ùèÑò<9a>ï^[^B^?^@é
à¤\t^F^@^@
```

貌似所有使用`gzexe`加密的脚本, 在乱码之前的部分都是相同的, 所以很容易判断其加密类型. 并且其解密方法也是相当简单, 只需要使用`gzexe -d 待解密文件`, 就可以得到原文件. 正所谓"防君子不防小人". 如下

```
$ gzexe -d test.sh
```

这样, `test.sh`就又被还原成了原文件.

------

## 我的尝试

说真的, `gzexe`这种加密方法, 不能加入自己的密码进行混淆, 感觉好鸡肋. 我尝试对同一个脚本进行多次加密, 这样, 在别人无法猜测脚本加密的具体次数的情况下依然有相当大的安全性. (突然觉得自己是一个天才︿(￣︶￣)︿)

然而愿望是美好的, 过程是"曲折"的, 但结果是不可能的...(⊙﹏⊙)

过程如下:

创建一个脚本

```
$ vim test.sh
```

它可以输出`hello + 第一个参数`

```
$ bash test.sh general
hello general
```

加密它

```
$ gzexe test.sh 
test.sh:	 -7.4%
```

功能正常

```
$ bash test.sh general
hello general
```

再加密, 失败

```
$ gzexe test.sh 
/usr/bin/gzexe: test.sh is already gzexe'd
```

猜测gzexe判断当前目录是否存在`~`结尾的同名文件

```
$ ls
test.sh  test.sh~
```

果断删掉

```
$ rm test.sh~
rm: remove regular file ‘test.sh~’? y
```

再次加密, 又失败, 绝望

```
$ gzexe test.sh 
/usr/bin/gzexe: test.sh is already gzexe'd
```

很好, 现在知道了, `gzexe`应该是往加密后的文件里加了什么标识, 所以拒绝再次加密. 而且这个标识我们是没办法修改的(别问我为什么, 我把加密后的文件前面未乱码部分和乱码部分都做了修改, 然而...┑(￣Д ￣)┍)

好了, 如果只是为了有趣, 可以拿`gzexe`玩玩, 但是为了安全性, 不推荐`gzexe`, 可以尝试另一个工具`shc`.

结束.