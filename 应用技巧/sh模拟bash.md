# sh模拟bash

某些镜像中不存在`bash`只能用`sh`(如`busybox`), 但某些代码中可能指定了`/bin/bash`去执行脚本, 可以使用如下方式模拟`bash`工具.

创建`/bin/bash`文件, 写入如下内容.

```bash
#!/bin/sh
/bin/sh "$@"
```

注意赋予755执行权限.
