
## 

我们知道, `unshare --mount`可以用来模拟一个隔离的 mount ns, 但是默认情况下, `unshare`会将新 mount ns 里面的所有挂载点的类型设置成`private`.

如果在系统中已经存在了一些被标记为 shared 的 mountpoint 挂载点, 在`unshare --mount`时, 新的 mount ns 会继承这些挂载点, 但是这些挂载点会失去原本的标记, 全部变为`private`.

```
unshare --mount --propagation unchanged bash
```
