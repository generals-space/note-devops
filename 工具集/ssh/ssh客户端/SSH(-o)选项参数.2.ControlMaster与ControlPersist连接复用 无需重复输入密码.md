# SSH(-o)选项参数.2.ControlMaster与ControlPersist连接复用 无需重复输入密码

参考文章

1. [使用ssh 的ControlMaster实现不用每次ssh都输入密码](https://www.jianshu.com/p/7e43fa159851)

`ControlMaster`模式, 可以复用之前已经建立的连接. 所以开启这个功能之后, 如果已经有一条到relay的链接, 那么再连接的时候, 就不需要再输入密码了. 

`ControlPersist` 参数的含义就是在最后一个连接关闭之后也不真正的关掉连接, 这样后面再连接的时候就还是不用输入密码. 

启用这两个功能, 就可以解决ssh登录时每次都需要重复输入密码的问题了. 
