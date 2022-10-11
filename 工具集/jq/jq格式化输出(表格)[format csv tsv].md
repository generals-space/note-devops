参考文章

1. [How to format a JSON string as a table using jq?](https://stackoverflow.com/questions/39139107/how-to-format-a-json-string-as-a-table-using-jq)
2. [Convert JSON to table, with headers of "Key" and "Value"](https://unix.stackexchange.com/questions/701158/convert-json-to-table-with-headers-of-key-and-value)

```
echo '{
	"InstanceTypes": {
		"InstanceType": [
			{
				"CpuArchitecture": "X86",
				"CpuCoreCount": 1,
				"InstanceFamilyLevel": "EntryLevel",
				"InstanceTypeFamily": "ecs.t1",
				"InstanceTypeId": "ecs.t1.xsmall",
				"MemorySize": 0.5
			}
        ]
    }
}' | jq -r '.InstanceTypes.InstanceType[] | [.InstanceTypeId,.CpuCoreCount,.MemorySize] | @tsv'
```

结果为

```
ecs.t1.xsmall	1	0.5
```

> 加表头就比较麻烦了, 因为要考虑不同字段长度的问题.

注意, 传入`@tsv`或`@csv`的数据, 必须是数组类型.

**错误**

```console
$ echo xxx | jq -r '.InstanceTypes.InstanceType[] | .InstanceTypeId,.CpuCoreCount,.MemorySize'
ecs.t1.xsmall
1
0.5
```

**正确**

```console
$ echo xxx | jq -r '.InstanceTypes.InstanceType[] | [.InstanceTypeId,.CpuCoreCount,.MemorySize]'
[
  "ecs.t1.xsmall",
  1,
  0.5
]
[
  "ecs.t2.xsmall",
  2,
  1
]
```
