参考文章

1. [Cannot access Kibana dashboard](https://stackoverflow.com/questions/51972423/cannot-access-kibana-dashboard)

为了能更简单的访问kibana, 尝试将 kibana 的 configMap 的 server.basePath 改成如下配置

```
server.basePath: /
```

但是kibana启动失败, 报错如下

```console
$ k logs -f hjl-es-0904-01-kibana-0
FATAL { ValidationError: child "server" fails because [child "basePath" fails because ["basePath" with value "&#x2f;" fails to match the start with a slash, don't end with one pattern]]
    at Object.exports.process (/usr/share/kibana/node_modules/joi/lib/errors.js:181:19)
    at _validateWithOptions (/usr/share/kibana/node_modules/joi/lib/any.js:651:31)
# Please edit the object below. Lines beginning with a '#' will be ignored,
    at root.validate (/usr/share/kibana/node_modules/joi/lib/index.js:121:23)
    at Config._commit (/usr/share/kibana/src/server/config/config.js:114:35)
    at Config.set (/usr/share/kibana/src/server/config/config.js:84:10)
    at Config.extendSchema (/usr/share/kibana/src/server/config/config.js:57:10)
    at _lodash2.default.each.child (/usr/share/kibana/src/server/config/config.js:46:14)
    at arrayEach (/usr/share/kibana/node_modules/lodash/index.js:1289:13)
    at Function.<anonymous> (/usr/share/kibana/node_modules/lodash/index.js:3345:13)
    at Config.extendSchema (/usr/share/kibana/src/server/config/config.js:45:31)
    at new Config (/usr/share/kibana/src/server/config/config.js:36:10)
    at Function.withDefaultSchema (/usr/share/kibana/src/server/config/config.js:29:12)
    at KbnServer.module.exports (/usr/share/kibana/src/server/config/setup.js:13:39)
    at /usr/share/kibana/src/server/kbn_server.js:156:20
    at next (native)
    at step (/usr/share/kibana/src/server/kbn_server.js:77:191)
  isJoi: true,
  name: 'ValidationError',
  details:
   [ { message: '"basePath" with value "&#x2f;" fails to match the start with a slash, don\'t end with one pattern',
       path: 'server.basePath',
       type: 'string.regex.name',
       context: [Object] } ],
```

其实应该改成`server.basePath: ""`, 或者干脆将该配置删除, 使用默认值, 然后重启即可.
