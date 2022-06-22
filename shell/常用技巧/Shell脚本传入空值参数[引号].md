# Shell脚本传入空值参数[引号]

参考文章

1. [Pass empty variable in bash](https://stackoverflow.com/questions/19376648/pass-empty-variable-in-bash)

`bash.sh`

```bash
echo $1 $2 $3
echo "$1" "$2" "$3"
```

```console
# bash bash.sh 1 '' 3
1 3
1  3
```

注意区别
