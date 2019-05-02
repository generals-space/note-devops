# Saltstack自定义模块编写(一)

参考文章

1. [salt stack 自定义编写modules和自定返回处理returners](http://www.linuxyw.com/198.html)

2. [RETURNERS - 官方文档](https://docs.saltstack.com/en/latest/ref/returners/index.html)

实验环境:

- Master: 172.32.100.232

- Minion1: 172.32.100.231

- Minion2: 172.32.100.233

## 1. 简单模块编写

Master上创建存放模块的目录

```
$ mkdir -pv /srv/salt/_modules
$ cd /srv/salt/_modules
```

编写一个简单的模块`xyz.py`

```py
#coding:utf-8
import random
def test():
    '''随机一个1到100的数为双数就返回True'''
    return random.randint(1,100) % 2 == 0

def echo(text):
    return text
```

我们现在编写的模块是放在mater节点上的, 实际上要执行的话需要将模块分发到minion节点. saltstack提供了一个命令来执行这个下发模块的操作, 在master上执行

```
$ salt '*'  saltutil.sync_modules
172.32.100.231:
    - modules.xyz
172.32.100.233:
    - modules.xyz
```

OK, 现在就可以执行了. 模块文件中每一个函数都可以被执行(...Maybe)

```
$ salt '*' xyz.test
172.32.100.231:
    True
172.32.100.233:
    False

$ salt '*' xyz.echo 'hehe'
172.32.100.231:
    hehe
172.32.100.233:
    hehe
```

### 1.1 关于返回值

模块中所有函数的返回值默认为字典类型, 上面的'hehe'虽然传入的是字符串, 但master得到的还是字典. 可以在模块开头通过如下语句定义各个函数的返回值类型

```py
#定义输出格式，不定义的话默认为字典
__outputter__ = {
    'echo': 'txt'
}
```

记得重新下发模块

```
salt '*'  saltutil.sync_modules
```

再次执行`echo`

```
$ salt '*' xyz.echo 'hehe'
172.32.100.233: hehe
172.32.100.231: hehe
```

## 2. 引用salt的其他模块

创建新模块`mycmd.py`

```py
#coding:utf-8
def run(*t, **kv):
    '''引用salt本身的模块'''
    ret = __salt__['cmd.run'](*t, **kv)
    return ret
```

下发

```
$ salt '*'  saltutil.sync_modules
```

执行

```
$ salt '*' mycmd.run 'ls /tmp'
172.32.100.231:
    tmpdNDe4i
    vmware-root
172.32.100.233:
    tmpEkKIhj
    vmware-root
```
