# sed+find修改指定条件下的文件内容

这是对`sed+grep`的强化应用, `sed`默认会修改所有目标文件. 对 **文件名(比如后缀名)**, **修改时间** 等有要求的情况, 可以配合使用`find`. 

比如在如下目录结构中, 要在所有`.html`文件的第一行添加`<!DOCTYPE>`.

```
$ tree
.
├── common
│   └── header.html
├── css
├── index.html
└── js

$ sed -i 'N;1i\<!DOCTYPE>' ./*
sed: couldn't edit ./common: not a regular file
```

首先`find`找出所有`.html`文件, 可以看到结果信息中包含着目标文件的路径信息, 这正是我们想要的.

```
$ find ./ -name '*.html'
./common/header.html
./index.html
```

然后用`xargs`将查找到的文件作为参数传给`sed`.

```
$ find ./ -name '*.html' | xargs sed -i 'N;2i\<!DOCTYPE>'
```

注意: `sed`指定行号时, 实际上指定行号=目标行号+1

也可以使用`find`自带的对查找出的文件进行指定操作的`-exec`选项, 其中`{}`表示查找到的文件.

```
$ find ./ -name '*.html' -exec sed -i 'N;2i\<!DOCTYPE>' {} \;
```
