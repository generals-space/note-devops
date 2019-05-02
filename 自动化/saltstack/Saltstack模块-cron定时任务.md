# Saltstack模块-cron定时任务.md

## 1. 查看

`cron.raw_cron 目标用户`可以查看指定用户下的cron列表, 用户名无法用通配符.

```
$ salt '*' cron.raw_cron root
172.32.100.233:
    * * * * * echo 1 > /tmp/echos
172.32.100.231:
    * * * * * echo 1 > /tmp/echos
```

另外, 还有一个`cron.list_tab 目标用户`命令, 可以实现同样的功能, 但是输出信息的格式不同. 如下

```
salt '*' cron.list_tab root
172.32.100.231:
    ----------
    crons:
        |_
          ----------
          cmd:
              echo 3 > /tmp/echos
          comment:
              echos
          commented:
              False
          daymonth:
              *
          dayweek:
              *
          hour:
              *
          identifier:
              None
          minute:
              *
          month:
              *
    env:
    pre:
        - * * * * * echo 1 > /tmp/echos
    special:
172.32.100.233:
    ----------
    crons:
        |_
          ----------
          cmd:
              echo 3 > /tmp/echos
          comment:
              echos
          commented:
              False
          daymonth:
              *
          dayweek:
              *
          hour:
              *
          identifier:
              None
          minute:
              *
          month:
              *
    env:
    pre:
        - * * * * * echo 1 > /tmp/echos
    special:
```

`pre`表示的是更新前的规则, 至于如何更新, 会在下面介绍.

## 2. 添加

为目标用户添加定时任务

`cron.set_job 目标用户 cron时间规则 指定命令 [注释 [identifier]]`

其中cron时间规则的`分`, `时`, `日`, `月`, `周`必须要分成5个参数字段来写...`'* * * * *'`会报错的. 

指定命令也需要用空格包裹, 表示单个参数

```
$ salt '*' cron.set_job root '*' '*' '*' '*' '*' 'echo 3 > /tmp/echos'
172.32.100.233:
    new
172.32.100.231:
    new
$ salt '*' cron.raw_cron root
172.32.100.231:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
    * * * * * echo 3 > /tmp/echos
172.32.100.233:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
    * * * * * echo 3 > /tmp/echos
```

## 3. 更新

没有提供更新的方法, 只能通过`set_job`本身完成.

因为`cron`模块将`目标命令`作为确认一条规则的唯一标识. 目标命令都完全一致时才会替换而不是新增, 可以为一条命令修改时间规则, 也可以为其修改注释.

我们先尝试修改一条命令的时间规则

```
$ salt '*' cron.set_job root '*' '*' '*' '*' 1 'echo 3 > /tmp/echos'
172.32.100.231:
    updated
172.32.100.233:
    updated
You have new mail in /var/spool/mail/root
$ salt '*' cron.raw_cron root
172.32.100.231:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
    * * * * 1 echo 3 > /tmp/echos
172.32.100.233:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
    * * * * 1 echo 3 > /tmp/echos

```

------

现在我们尝试添加注释

```
$ salt '*' cron.set_job root '*' '*' '*' '*' '*' 'echo 3 > /tmp/echos' comment='现在给echo 3添加 注释'
```

添加identifier

```
$ salt '*' cron.set_job root '*' '*' '*' '*' '*' 'echo 3 > /tmp/echos' comment='现在给echo 3添加 注释' identifier='aaa'
```

...完美!

## 删除

`cron.rm_job 目标用户 目标命令 [分, 时, 日, 月, 周, identifier]`

[分, 时, 日, 月, 周, identifier]是作为限制条件, 如果不匹配就不会删除. 因为在salt管理下, 一条命令有会有一个规则, 所以其实也没什么必要管这个, 当然, 还是更稳妥一点.

注意: 删除一条拥有identifier的规则时, 必须要加上identifier参数限制, 否则cron会去寻找与目标命令匹配但是identifier为空的规则, 这样是找不到的.

```
$ salt '*' cron.rm_job root 'echo 3 > /tmp/echos'
172.32.100.231:
    absent
172.32.100.233:
    absent
```

正确方法是, 命令与各种限定条件都匹配, 这样也更安全.

```
$ salt '*' cron.rm_job root 'echo 3 > /tmp/echos' identifier='aaa'
172.32.100.231:
    removed
172.32.100.233:
    removed
$ salt '*' cron.raw_cron root
172.32.100.233:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
172.32.100.231:
    * * * * * echo 1 > /tmp/echos
    # Lines below here are managed by Salt, do not edit
```