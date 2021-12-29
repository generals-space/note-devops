curl --include --no-buffer --header "Connection: Upgrade" --header "Upgrade: websocket" --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ=="  --header "Sec-WebSocket-Version: 13" 172.22.248.66:33003/xxx

1. Sec-WebSocket-Key 和 Sec-WebSocket-Version 应该是必须的
2. 请求地址不必加`ws://`前缀.

