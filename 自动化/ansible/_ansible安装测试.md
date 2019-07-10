# ansible 安装配置测试

```
ansible --version
Traceback (most recent call last):
  File "/usr/bin/ansible", line 44, in <module>
    import ansible.constants as C
ImportError: No module named ansible.constants
```

yum 安装ansible, pip也需要安装ansible...


```
ansible docker -m command -a 'uptime'
172.17.0.2 | SUCCESS | rc=0 >>
 07:50:44 up 203 days,  5:50,  1 user,  load average: 0.06, 0.18, 0.13

172.17.0.4 | SUCCESS | rc=0 >>
 07:50:54 up 203 days,  5:50,  1 user,  load average: 0.05, 0.18, 0.13
```

ansible的command模块不支持管道...而shell模块可以

ansible模块的存在意义, 有了command/shell模块完全可以替代所有其他模块

unarchive: src=/tmp/redis-3.0.7.tar.gz dest=/usr/local
file or module does not exist
需要再加上copy=no
参考https://github.com/ansible/ansible-modules-core/issues/1443


自动化部署不能完成所有的事情, 它能做的只是把单台服务器上的步骤推送到多台而已. 所以你首先需要把自己要做的功能能用shell脚本抽象出来, 否则还是不够用. 任何自动化工具都帮不了你.

环境搭建还是可以的, 像fastdfs, redis集群搭建, jar包/xml配置文件替换，，，简直痴人说梦

http://sofar.blog.51cto.com/353572/1579894/
http://os.51cto.com/art/201409/451927_all.htm
http://www.ansible.com.cn/docs/playbooks_best_practices.html#id14

------

## 关于ansible变量默认值的尝试

common/vars/main.yml中的变量, 可以被common角色本身获取, 也可以在其他角色的meta/main.yml通过角色依赖的方式获取. 而在common/default/main.yml中设置的变量, 可以通过在主调playbook中通过`include role`引入, 也可以通过在主调角色的meta/main.yml通过角色依赖方式引入.

需要注意的是, 如果定义了一个字典形式的变量默认值, 比如`{service: {name: 'cache', port: 8080}}`, 那么在主调角色中, 变量`service`必须同时拥有`name`, `port`两个键, 同时覆盖, 不能只覆盖service字典中的`name`字段(当然, 如果没有`service`变量, 就会使用默认值).

另外, 不能通过include语句在tasks/main.yml, vars/main.yml中引入存放默认变量的配置文件, 因为直接引入变量配置文件, 同名的键会引起冲突.

------

ansible的yml文件key和value不能有中划线, 在此规定, 键名按照驼峰命名法, 键值使用下划线连接

------

ansible主调文件a.yml中可以使用include包含b.yml,c.yml;
a.yml
- include b.yml
- include c.yml
命令行执行时可以使用`--limit`参数指定某个特定的被调文件: `ansible-playbook a.yml --limit b`

------
--tag标记对应`group_vars`与`host_vars`目录中设置的变量

cat group_vars/a
ntp: www.ntp-server.com

然后在(一般是)`common`下的tasks/main.yml中为每条ntp相关的task下面都加上`tags: ntp`标记
这样, 在`ansible-playbook site.yml --tags ntp`就可以单独执行标记为`tags: ntp`的task了

------

`remote_user: gluon` 指令并不是拥有目标服务器的root的公钥, 执行ansible时就会通过`su`切换至`gluon`用户, 它没有那么只能, ansible执行端必须拥有目标服务器`gluon`的公钥才行.

------

shell命令虽然可以用bash管道, 但是不能使用&& ||等操作符连续执行命令, 比如

```
shell: su - general && ls
```

ls命令列出的依然是remote_user指定用户的家目录内容.

也就是说, shell模块虽然可以执行一连串bash命令, 但这些命令是不相关的, 后者也没办法取到前者的返回值, 它们相互独立.


`with_items`指令, 还有`with_dic`, 放在一个task中. 

```yml
- name: add several users
  user: name={{ item }} state=present groups=wheel
  with_items:
     - testuser1
     - testuser2
```

输出debug信息到文件

```yml
- hosts: all
  tasks:
    # emit a debug message containing the content of each file.
    - debug:
        msg: "{{ item }}"
      with_file:
        - first_example_file
        - second_example_file
```

如果不在主调yml文件中显示include某个角色, 就没有办法使用它下面的默认变量.

`ansible ImportError: No module named yum`