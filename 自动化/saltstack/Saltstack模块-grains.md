# Saltstack模块-grains

参考文章

1. [Saltstack系列4：Saltstack之Grains组件](http://www.cnblogs.com/MacoLee/p/5757299.html)

grains是Saltstack最重要的组件之一，grains的作用是手机被控主机的基本信息，这些信息通常都是一些静态类的数据，包括CPU、内核、操作系统、虚拟化等，在服务器端可以根据这些信息进行灵活定制，管理员可以利用这些信息对不同业务进行个性化定制。

`salt '*' grains.ls`:               查看grains分类
`salt '*' grains.items`:            查看grains所有信息
`salt '*' grains.item osrelease`:   查看grains某个信息
`salt '*' grains.item osrelease osarch`: 查看多个指定字段信息