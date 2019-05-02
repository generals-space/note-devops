# Supervisor管理进程(二)配置文件详解

参考文章

1. [使用 supervisor 管理进程](http://www.ttlsa.com/linux/using-supervisor-control-program/)

2. [supervisord监控详解](http://www.2cto.com/os/201406/306622.html)

3. [Linux 进程管理与监控（supervisor and monit）](http://tchuairen.blog.51cto.com/3848118/1827716)

4. [supervisor(一)基础篇](http://lixcto.blog.51cto.com/4834175/1539136)及其后续

```ini
; Notes:
;  - 不支持'~'或是"$HOME"这种变量形式, 用户主目录的环境变量可以使用"%(ENV_HOME)s"表示
;  - 分号表示注释, 但是行内注释需要分号前预留一个空格. 比如'a=b;这里是注释'是错误的, 'a=b ;这里是注释'才是正确的
;  - echo_supervisord_conf命令可以得到最原始的, 未经修改的配置文件模板, 可以当作参考

; web管理界面配置, 通过sock文件与http服务器通信
[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                      ; socket file mode (default 0700)
chown=root:root                 ; socket file uid:gid owner
username=devops                 ; (default is no username (open server))
password=hh1q2w3edd4r5t6y       ; (default is no password (open server))

; web管理界面配置, 通过ip:port与http服务器通信, 也可以直接对外服务, 是远程`supervisorctl`工具与web server的管理接口.
[inet_http_server]              ; inet (TCP) server disabled by default
port=*:19001                    ; (ip_address:port specifier, *:port for all iface)
username=devops                 ; (default is no username (open server))
password=hh1q2w3edd4r5t6y       ; (default is no password (open server))

[supervisord]
logfile=/var/log/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB        ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10           ; (num of main logfile rotation backups;default 10)
loglevel=info                ; (log level;default info; others: debug,warn,trace)
pidfile=/var/run/supervisord.pid       ; (supervisord pidfile;default supervisord.pid)
nodaemon=false               ; (start in foreground if true;default false)
minfds=1024                  ; 这个是最少系统空闲的文件描述符，低于这个值supervisor将不会启动。默认1024
minprocs=200                 ; 最小可用的进程描述符，低于这个值supervisor也将不会正常启动。默认200
;umask=022                   ; (process file creation umask;default 022)
user=root                 ; (default is current user, required if root)
;identifier=supervisor       ; (supervisord identifier, default is 'supervisor')
;directory=/tmp              ; 当supervisord作为守护进程运行的时候，启动supervisord进程之前，会先切换到这个目录
nocleanup=true              ; 这个参数当为false的时候，会在supervisord进程启动的时候，把以前子进程产生的日志文件(路径为AUTO的情况下)清除掉。想要看历史日志，当可以设置为true. 默认为false
;childlogdir=/tmp            ; 当子进程日志路径为AUTO的时候，子进程日志文件的存放路径。默认路径为$TEMP, 可以通过`python -c "import tempfile;print tempfile.gettempdir()"`命令查看
;environment=KEY="value"     ; (key value pairs to add to environment)
;strip_ansi=false            ; 这个选项如果设置为true，会清除子进程日志中的所有ANSI 序列, 即\n,\t这些字符。默认为false

; rpc配置块是supervisor远程操作的接口, ctl命令与web管理都需要这个接口
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

; supervisorctl管理接口, 也是supervisorctl工具需要加载的配置, 通过.sock文件或是端口任意一种方式通信
; 只要这里配置的username与password与上面unix|inet形式的http server的认证口令一致, 就可以管理supervisord(当然也可以在命令行中指定)
; 通过ip:port通信的方式, supervisorctl可以管理远程的supervisord服务
[supervisorctl]
;serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket
serverurl=http://127.0.0.1:19001 ; use an http:// url to specify an inet socket
username=devops              ; should be same as http_username if set
password=hh1q2w3edd4r5t6y                ; should be same as http_password if set
;prompt=mysupervisor         ; cmd line prompt (default "supervisor")
;history_file=~/.sc_history  ; use readline history if available

; 被管理进程的配置块, 建议写在include块中, 各个子服务分开
;[program:theprogramname]
;command=/bin/cat              ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
;exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (default 10)
;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (default 10)
;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;environment=A="1",B="2"       ; process environment additions (def no adds)
;serverurl=AUTO                ; override serverurl computation (childutils)

; 事件监听器配置
;[eventlistener:theeventlistenername]
;command=/bin/eventlistener    ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;events=EVENT                  ; event notif. types to subscribe to (req'd)
;buffer_size=10                ; event buffer queue size (default 10)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=-1                   ; the relative start priority (default -1)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; autorestart if exited after running (def: unexpected)
;exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=false         ; redirect_stderr=true is not allowed for eventlisteners
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (default 10)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (default 10)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;environment=A="1",B="2"       ; process environment additions
;serverurl=AUTO                ; override serverurl computation (childutils)

; 进程组配置块, 多个相关进程可归为一组, 方便管理
;[group:thegroupname]
;programs=progname1,progname2  ; each refers to 'x' in [program:x] definitions
;priority=999                  ; the relative start priority (default 999)

; include配置块可以指定子配置文件, 
; 支持通配符. 多个文件可以使用空格或换行.
; 支持以此配置文件为基准的相对路径
;[include]
files = /etc/nginx.ini
```