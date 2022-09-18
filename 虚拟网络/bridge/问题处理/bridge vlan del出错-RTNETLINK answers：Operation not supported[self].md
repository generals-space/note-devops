# bridge vlan del出错-RTNETLINK answers：Operation not supported[self]

```
# bridge vlan show
port	vlan ids
virbr0	 1 PVID Egress Untagged
virbr0-nic	 1 PVID Egress Untagged
br0	 1 PVID Egress Untagged
vnet0	 1 PVID Egress Untagged
```

下面的命令是正常的

```
bridge vlan delete dev vnet0 vid 1
```

但是下面这句就出错了

```console
$ bridge vlan del dev br0 vid 1
RTNETLINK answers: Operation not supported
```

这是因为, br0接口是bridge本身的条目, 在操作时要添加`self`标记.

```
bridge vlan del dev br0 vid 1 self
```

这样就对了.
