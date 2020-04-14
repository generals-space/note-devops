# EOF标记未放在行首导致unexpected end of file

```bash
    cat  >>... << EOF
        ...
    EOF
```

执行脚本报如下错误

```
./xxx.sh: line 100: warning: here-document at line 72 delimited by end-of-file (wanted `EOF')
./xxx.sh: line 101: syntax error: unexpected end of file
```

解决办法是将第2个`EOF`标记放在行首.

------

同样还是`<< EOF ... EOF`的使用, 脚本如下

```bash
#!/bin/bash  
whoami  
su - general << ! 
whoami  
exit  
! 
whoami
```

执行时有一个warning如下

```
./sus.sh: line 7: warning: here-document at line 3 delimited by end-of-file (wanted `!')
```

原因是, 第2个`!`前后不能有空格, 当然也不能有其他任何字符.
