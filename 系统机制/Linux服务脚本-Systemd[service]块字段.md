Type: 定义启动时的进程行为。它有以下几种值。

Type=simple: 默认值，执行ExecStart指定的命令，启动主进程

Type=forking: 以 fork 方式从父进程创建子进程，创建后父进程会立即退出

Type=oneshot: 一次性进程，Systemd 会等当前服务退出，再继续往下执行

Type=dbus: 当前服务通过D-Bus启动

Type=notify: 当前服务启动完毕，会通知Systemd，再继续往下执行

Type=idle: 若有其他任务执行完毕，当前服务才会运行

ExecStart: 启动当前服务的命令

ExecStartPre: 启动当前服务之前执行的命令

ExecStartPost: 启动当前服务之后执行的命令

ExecReload: 重启当前服务时执行的命令

ExecStop: 停止当前服务时执行的命令

ExecStopPost: 停止当其服务之后执行的命令

RestartSec: 自动重启当前服务间隔的秒数

Restart: 定义何种情况 Systemd 会自动重启当前服务，可能的值包括always（总是重启）、on-success、on-failure、on-abnormal、on-abort、on-watchdog

TimeoutSec: 定义 Systemd 停止当前服务之前等待的秒数

Environment: 指定环境变量


注意, `ExecStart`, `ExecStartPre`, `ExecStartPost`这三者是串行执行的, 有任何一个中指定的命令出错, 都会导致服务启动失败.

如果不是直接指定命令, 而是指定运行某个脚本, 那么脚本的返回值就会作为执行结果. 所以如果脚本中有可能会出错但是无关紧要的命令, 不能作为最后一句, 最好最后添加一行`exit 0`来保证不会中断.