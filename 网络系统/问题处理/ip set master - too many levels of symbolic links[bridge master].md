# ip set master - too many levels of symbolic links

参考文章

1. [How could one add bridge to yet another bridge?](http://intelligentsystemsmonitoring.com/community/how-could-one-add-bridge-to-yet-another-bridge/)

把一个 bridge master 到另一个 bridge 时可能会出现这个问题.

```log
$ ip link add br0 type bridge
$ ip link add br1 type bridge
$ ip link set br0 master br1
RTNETLINK answers: Too many levels of symbolic links
```

