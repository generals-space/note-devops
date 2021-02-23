# sed-问题处理expects followed by text

```
$ sed -i 's/this._websocket = new WebSocket(uri, protocols);/this._websocket = new WebSocket(uri, ["binary", "base64"]);/' core/websock.js
sed: 1: "core/websock.js": command c expects \ followed by text
```

貌似是因为`sed`后面的文件只能在同级目录?
