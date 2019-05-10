# jar命令解压与压缩

参考文章

1. [把JAR文件解压了，怎样再把它压回去？？](https://zhidao.baidu.com/question/126789019.html)

2. [Linux替换jar或war中的文件](http://blog.csdn.net/yyhjava/article/details/53895537)

3. [jar包压缩与解压](http://blog.csdn.net/leon__zhou/article/details/8286428)

如果要修改jar包中的文件, 不能直接用解压工具解压 -> 修改 -> 压缩, 这样得到的jar包文件, 在执行时会得到如果错误

```
$ java -jar xxx.jar
no main manifest attribute, in xxx.jar
```

> 正常情况下，java打包成jar包需要在`MANIFEST.MF`中指定`Main-Class`项以便运行`java -jar XXX.jar`时找到对应的主类。因为`-jar`的含义就是后面跟的jar包是有main class可独立运行，所以需要在打包成jar包时指定这个类。

我尝试了下通过`jar`命令的`-m`在打包时指定`.MF`文件, 但是虽然打包成功了, 但好像无效, 而且打包命令的退出码为1, 这就表示有问题..

```
$ jar -cvf xxx.jar BOOT-INF/ META-INF/ org/ -m META-INF/MANIFEST.MF
...
echo $?
1
```

------

暂时不去管用jar命令打包的问题, 如果只是要修改jar包中某个文件的内容, 可以用如下方式.

在windows下, 可以用解压工具直接打开jar包, 修改目标文件, 然后直接保存到jar包中.

在linux下, 可以将目标jar包解压, 修改后再将目标文件更新到jar包中. 使用jar的`-u`参数. 如下

```
$ jar -xf xxx.jar
## 一些修改
$ sed -in "s/app.hdc.addr/${HDC_ADDR}/g" BOOT-INF/classes/conf.properties 
$ jar -uvf xxx.jar BOOT-INF/classes/conf.properties
```

`-u`参数可以将**指定文件**更新到jar包内. 注意**目标文件**的路径, 必须是与jar包内部的路径匹配, 如果如果写成这样`jar -uvf xxx.jar /opt/drgs/BOOT-INF/classes/conf.properties`, 那jar包里就多出来一个`/opt/drgs/BOOT-INF/classes/conf.properties`的文件了...