# Linux-top输出详解

参考文章

1. [linux top命令详解与输出结果说明](https://www.jb51.net/article/135852.htm)
    - 最全

top命令的结果分为两个部分: 

1. 统计信息: 前五行是系统整体的统计信息; 
2. 进程信息: 统计信息下方类似表格区域显示的是各个进程的详细信息, 默认5秒刷新一次. 

## 1. 统计信息

### 1.1 第1行

Top 任务队列信息(系统运行状态及平均负载), 与uptime命令结果相同. 

第1段: 系统当前时间, 例如: 16:07:37
第2段: 系统运行时间, 未重启的时间, 时间越长系统越稳定. 格式: up xx days, HH:MM. 例如: 241 days, 20:11, 表示连续运行了241天20小时11分钟
第3段: 当前登录用户数, 例如: 1 user, 表示当前只有1个用户登录
第4段: 系统负载, 即任务队列的平均长度, 3个数值分别统计最近1, 5, 15分钟的系统平均负载

系统平均负载: 单核CPU情况下, 0.00 表示没有任何负荷, 1.00表示刚好满负荷, 超过1侧表示超负荷, 理想值是0.7; 
多核CPU负载: CPU核数 * 理想值0.7 = 理想负荷, 例如: 4核CPU负载不超过2.8何表示没有出现高负载. 

### 1.2 第2行

Tasks 进程相关信息

第1段: 进程总数, 例如: Tasks: 231 total, 表示总共运行231个进程
第2段: 正在运行的进程数, 例如: 1 running,
第3段: 睡眠的进程数, 例如: 230 sleeping,
第4段: 停止的进程数, 例如: 0 stopped,
第5段: 僵尸进程数, 例如: 0 zombie

### 1.3 第3行

Cpus CPU相关信息.

> 如果是多核CPU, 按数字1可显示各核CPU信息, 此时1行将转为Cpu核数行, 数字1可以来回切换. 

1. `us`: 用户空间占用CPU百分比, 例如: Cpu(s): 12.7%us,
2. `sy`: 内核空间占用CPU百分比, 例如: 8.4%sy,
3. `ni`: 用户进程空间内改变过优先级的进程占用CPU百分比, 例如: 0.0%ni,
4. `id`: 空闲CPU百分比, 例如: 77.1%id.
5. `wa`: 等待输入输出的CPU时间百分比, 例如: 0.0%wa,
6. `hi`: CPU服务于硬件中断所耗费的时间总额, 例如: 0.0%hi,
7. `si`: CPU服务软中断所耗费的时间总额, 例如: 1.8%si,
8. `st`: Steal time 虚拟机被hypervisor偷去的CPU时间(如果当前处于一个hypervisor下的vm, 实际上hypervisor也是要消耗一部分CPU处理时间的)

> 一般来说, us + sy + id = 100

### 1.4 第4行

Mem 内存相关信息(Mem: 12196436k total, 12056552k used, 139884k free, 64564k buffers)

第1段: 物理内存总量, 例如: Mem: 12196436k total,
第2段: 使用的物理内存总量, 例如: 12056552k used,
第3段: 空闲内存总量, 例如: Mem: 139884k free,
第4段: 用作内核缓存的内存量, 例如: 64564k buffers

### 1.5 第5行

Swap 交换分区相关信息(Swap: 2097144k total, 151016k used, 1946128k free, 3120236k cached)

第1段: 交换区总量, 例如: Swap: 2097144k total,
第2段: 使用的交换区总量, 例如: 151016k used,
第3段: 空闲交换区总量, 例如: 1946128k free,
第4段: 缓冲的交换区总量, 3120236k cached

## 2. 进程信息

在top命令中按`f`按可以查看显示的列信息, 按对应字母来开启/关闭列, 大写字母表示开启, 小写字母表示关闭. 带*号的是默认列. 

A: PID = (Process Id) 进程Id; 
E: USER = (User Name) 进程所有者的用户名; 
H: PR = (Priority) 优先级
I: NI = (Nice value) nice值. 负值表示高优先级, 正值表示低优先级
O: VIRT = (Virtual Image (kb)) 进程使用的虚拟内存总量, 单位kb. VIRT=SWAP+RES
Q: RES = (Resident size (kb)) 进程使用的、未被换出的物理内存大小, 单位kb. RES=CODE+DATA
T: SHR = (Shared Mem size (kb)) 共享内存大小, 单位kb
W: S = (Process Status) 进程状态. D=不可中断的睡眠状态,R=运行,S=睡眠,T=跟踪/停止,Z=僵尸进程
K: %CPU = (CPU usage) 上次更新到现在的CPU时间占用百分比
N: %MEM = (Memory usage (RES)) 进程使用的物理内存百分比
M: TIME+ = (CPU Time, hundredths) 进程使用的CPU时间总计, 单位1/100秒
b: PPID = (Parent Process Pid) 父进程Id
c: RUSER = (Real user name)
d: UID = (User Id) 进程所有者的用户id
f: GROUP = (Group Name) 进程所有者的组名
g: TTY = (Controlling Tty) 启动进程的终端名. 不是从终端启动的进程则显示为 ?
j: P = (Last used cpu (SMP)) 最后使用的CPU, 仅在多CPU环境下有意义
p: SWAP = (Swapped size (kb)) 进程使用的虚拟内存中, 被换出的大小, 单位kb
l: TIME = (CPU Time) 进程使用的CPU时间总计, 单位秒
r: CODE = (Code size (kb)) 可执行代码占用的物理内存大小, 单位kb
s: DATA = (Data+Stack size (kb)) 可执行代码以外的部分(数据段+栈)占用的物理内存大小, 单位kb
u: nFLT = (Page Fault count) 页面错误次数
v: nDRT = (Dirty Pages count) 最后一次写入到现在, 被修改过的页面数
y: WCHAN = (Sleeping in Function) 若该进程在睡眠, 则显示睡眠中的系统函数名
z: Flags = (Task Flags <sched.h>) 任务标志, 参考 sched.h
X: COMMAND = (Command name/line) 命令名/命令行