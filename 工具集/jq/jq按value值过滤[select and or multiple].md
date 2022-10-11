参考文章

1. [JQ to filter JSON by value](https://gist.github.com/ipbastola/2c955d8bf2e96f9b1077b15f995bdae3)
2. [JQ select filter with multiple arguments [duplicate]](https://stackoverflow.com/questions/46530167/jq-select-filter-with-multiple-arguments)
3. [JQ: Select multiple conditions](https://stackoverflow.com/questions/33057420/jq-select-multiple-conditions)

常规的`.key1,.key2,.key3`是根据key进行过滤, 相应的, `select()`可以根据value进行过滤.

```bash
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
}' | jq -r '.InstanceTypes.InstanceType[] | select((.CpuArchitecture | contains("X86")) and .MemorySize < 16)'
```

结果为

```json
{
  "CpuArchitecture": "X86",
  "CpuCoreCount": 1,
  "InstanceFamilyLevel": "EntryLevel",
  "InstanceTypeFamily": "ecs.t1",
  "InstanceTypeId": "ecs.t1.xsmall",
  "MemorySize": 0.5
}
```

由于上述两个条件对比的是不同key, 所以有点不一样. 

如果是比较同一个key, 会简单一点

```
select(.MemorySize <= 3 and .MemorySize >= 2)
```
