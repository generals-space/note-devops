# Shell脚本技巧-EOF标记嵌套应用

下面是命令行切换为`oracle`用户并启动监听器, 然后启动数据库的脚本.

```shell
su - oracle << EOF
lsnrctl start
sqlplus "/as sysdba" << EOF
startup
EOF
echo 'complete...'
```

最初是想写成这样的

```shell
su - oracle << EOF
lsnrctl start
sqlplus "/as sysdba" << EOF
startup
EOF
EOF
## 上面的EOF将被两个'<<'符号共用.
echo 'complete...'
```

但是最后一个`EOF`标记会出错: `EOF: command not found`.

可以认为, `EOF`结束标记将被所有`<< EOF`共用. 所以不要想着在两个结束的`EOF`之间做什么操作了...不可能实现的.