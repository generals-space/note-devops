# Linux查看系统/硬件信息

## 1. dmidecode应用

Dmidecode 这款软件允许你在 Linux 系统下获取有关硬件方面的信息。Dmidecode 遵循 SMBIOS/DMI 标准，其输出的信息包括 BIOS、系统、主板、处理器、内存、缓存等等。

### 1.1 简介

DMI (Desktop Management Interface, DMI)就是帮助收集电脑系统信息的管理系统，DMI信息的收集必须在严格遵照SMBIOS规范的前提下进行。 SMBIOS(System Management BIOS)是主板或系统制造者以标准格式显示产品管理信息所需遵循的统一规范。SMBIOS和DMI是由行业指导机构Desktop Management Task Force (DMTF)起草的开放性的技术标准，其中DMI设计适用于任何的平台和操作系统。

　　DMI充当了管理工具和系统层之间接口的角色。它建立了标准的可管理系统更加方便了电脑厂商和用户对系统的了解。DMI的主要组成部分是Management Information Format (MIF)数据库。这个数据库包括了所有有关电脑系统和配件的信息。通过DMI，用户可以获取序列号、电脑厂商、串口信息以及其它系统配件信息。

### 1.2 使用方法

dmidecode的输出格式一般如下：

```
Handle 0×0002 DMI type 2, 8 bytes
Base Board Information
Manufacturer:Intel
Product Name: C440GX+
Version: 727281-0001
Serial Number: INCY92700942
```

其中的前三行都称为记录头(recoce Header), 其中包括了：

1. recode id(handle): DMI表中的记录标识符，这是唯一的,比如上例中的Handle 0×0002。

2. dmi type id: 记录的类型，譬如说:BIOS，Memory，上例是`type 2`，即”Base Board Information”

3. recode size: DMI表中对应记录的大小，上例为8 bytes.（不包括文本信息，所有实际输出的内容比这个size要更大。）

记录头之后就是记录的值：

4. decoded values: 记录值可以是多行的，比如上例显示了主板的制造商(manufacturer)、model、version以及serial Number。

### 1.3 查看内存信息

`-t memory`可以查看所有内存相关信息, 包含了`-t 16`和`-t 17`两种, 前者是看内存插槽本身的信息, 后者是查看每个插槽对应的内存条的信息.

```
$ dmidecode -t 16
# dmidecode 2.12-dmifs
SMBIOS 2.6 present.

Handle 0x1000, DMI type 16, 15 bytes
Physical Memory Array                    ## 物理内存设备, 一个这东西有多个内存插槽, 安装在主板上(可能不只一个)
	Location: System Board Or Motherboard
	Use: System Memory
	Error Correction Type: Single-bit ECC
	Maximum Capacity: 96 GB          	## 支持最大扩展内存
	Error Information Handle: Not Provided
	Number Of Devices: 9                 ## 内存插槽数
```

------

```
$dmidecode -t 17
# dmidecode 2.12-dmifs
SMBIOS 2.6 present.

Handle 0x1100, DMI type 17, 28 bytes
Memory Device
	Array Handle: 0x1001
	Error Information Handle: Not Provided
	Total Width: 72 bits
	Data Width: 64 bits
	Size: 2048 MB                             ##  当前槽位内存条大小, 'No Module Installed'什么的说明当前槽位没插
	Form Factor: DIMM
	Set: 15                                        ## 貌似为当前槽位支持的最大内存
	Locator: PROC 2 DIMM 6
	Bank Locator: Not Specified
	Type: DDR3                                ## 型号
	Type Detail: Synchronous
	Speed: 1333 MHz                       ## 槽位上内存的速率, 没插就是'Unknown'
	Manufacturer: Not Specified
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified
	Rank: 2

...
```

### 1.4 CPU信息

```
$ dmidecode -t processor
# dmidecode 2.12-dmifs
SMBIOS 2.6 present.

Handle 0x0400, DMI type 4, 42 bytes
Processor Information
	Socket Designation: Proc 1
	Type: Central Processor
	Family: Quad-Core Xeon
	Manufacturer: Intel
	ID: A5 06 01 00 FF FB EB BF
	Signature: Type 0, Family 6, Model 26, Stepping 5
	Flags:
		FPU (Floating-point unit on-chip)
		VME (Virtual mode extension)
		DE (Debugging extension)
		PSE (Page size extension)
		TSC (Time stamp counter)
		MSR (Model specific registers)
		PAE (Physical address extension)
		MCE (Machine check exception)
		CX8 (CMPXCHG8 instruction supported)
		APIC (On-chip APIC hardware supported)
		SEP (Fast system call)
		MTRR (Memory type range registers)
		PGE (Page global enable)
		MCA (Machine check architecture)
		CMOV (Conditional move instruction supported)
		PAT (Page attribute table)
		PSE-36 (36-bit page size extension)
		CLFSH (CLFLUSH instruction supported)
		DS (Debug store)
		ACPI (ACPI supported)
		MMX (MMX technology supported)
		FXSR (FXSAVE and FXSTOR instructions supported)
		SSE (Streaming SIMD extensions)
		SSE2 (Streaming SIMD extensions 2)
		SS (Self-snoop)
		HTT (Multi-threading)
		TM (Thermal monitor supported)
		PBE (Pending break enabled)
	Version: Intel(R) Xeon(R) CPU E5504 @ 2.00GHz            
	Voltage: 1.4 V
	External Clock: 133 MHz
	Max Speed: 4800 MHz
	Current Speed: 2000 MHz
	Status: Populated, Enabled
	Upgrade: Socket LGA1366
	L1 Cache Handle: 0x0710
	L2 Cache Handle: 0x0720
	L3 Cache Handle: 0x0730
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified
	Core Count: 4                          ## 核心数
	Core Enabled: 4
	Thread Count: 4
	Characteristics:
		64-bit capable

```

## 2. `/proc/`目录

### 2.1 CPU信息

`cat /proc/cpuinfo`中的信息

- processor       逻辑处理器的id。

- physical id    物理封装的处理器的id。

- core id        每个核心的id。

- cpu cores      位于相同物理封装的处理器中的内核数量。

- siblings       位于相同物理封装的处理器中的逻辑处理器的数量。

```
## 1 查看物理CPU的个数
$ cat /proc/cpuinfo | grep "physical id"| sort | uniq| wc –l
## 2 查看逻辑CPU的个数
$ cat /proc/cpuinfo | grep "processor"| wc –l
## 3 查看CPU是几核
$ cat /proc/cpuinfo | grep "cores"| uniq
## 4 查看CPU的主频
$ cat /proc/cpuinfo | grep MHz| uniq 
```

## 3. hostnamectl

这个是CentOS7中的命令, 可以查看hostname值, 系统类型, 内核版本等信息. 它是systemd机制中`systemd-hostnamed.service`服务的客户端操作工具.

```
$ hostnamectl status
   Static hostname: localhost.localdomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 7bc63b73c29c49a8b16c98b90102dd38
           Boot ID: fb1752d30adc4260a71f2799d2b9ce92
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-327.28.3.el7.x86_64
      Architecture: x86-64
```

## 4. 其他命令

```
## 查看内核版本, CPU架构
$ uname -a
## 查看内核版本, 编译内核的GCC版本
$ cat /proc/version
## 查看发行版版本
$ cat /etc/issue
```