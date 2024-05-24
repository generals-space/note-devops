# CentOS 8下使用nmcli创建bond接口

参考文章

1. [7.3. NETWORK BONDING USING THE NETWORKMANAGER COMMAND LINE TOOL, NMCLI](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-network_bonding_using_the_networkmanager_command_line_tool_nmcli)
    - `nmcli`命令添加bond接口并连接`ethX`设备的示例步骤
2. [7.4. USING THE COMMAND LINE INTERFACE (CLI)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-network_bonding_using_the_command_line_interface#sec-Creating_Multiple_Bonds)
    - 使用`ifcfg`配置文件然后使用`nmcli`重启网络生效
    - 多网卡主机创建两组bond的方法示例
3. [【原创】CentOS8双网卡绑定](https://www.bbsmax.com/A/l1dypWO65e/)

主要就是在`/etc/sysconfig/network-scripts`目录下创建`ifcfg-br0`并修改`ifcfg-ethX`等后, 需要使用`nmcli c reload`创建网络使之生效.

另外, CentOS 8系统中, 修改后的`ethX`配置文件中的UUID不能变动, 否则会因为UUID与设备名称无法对应导致bond接口启动失败.

```log
$ nmcli.c
NAME          UUID                                  TYPE      DEVICE
docker0       96a63037-ce53-443e-930f-b0b6e4ea8dc0  bridge    docker0
ens224        e4014630-448b-5ad3-4992-f4678202147c  ethernet  ens224
ens160        ea74cf24-c2a2-ecee-3747-a2d76d46f93b  ethernet  --
System bond0  ad33d8b0-1f7b-cab9-9447-ba07f855b143  ethernet  --
$ nmcli.d
DEVICE   TYPE      STATE         CONNECTION
ens224   ethernet  connected     ens224
docker0  bridge    connected     docker0
ens160   ethernet  disconnected  --
lo       loopback  unmanaged     --
```
