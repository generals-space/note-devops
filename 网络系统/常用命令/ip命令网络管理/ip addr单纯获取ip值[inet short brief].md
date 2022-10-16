# ip addr单纯获取ip值[inet short brief]

```
$ ip -4 -brief addr ls dev eth0
eth0             UP             172.16.42.37/20
```

```
$ ip -4 -brief addr ls dev eth0 | awk -F' ' '{print $3}' | awk -F'/' '{print $1}'
172.16.42.37
```
