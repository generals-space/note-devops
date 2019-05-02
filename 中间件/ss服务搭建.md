# ss服务搭建

```sh
## 安装服务端程序
curl -o /etc/yum.repos.d/librehat-shadowsocks-epel-7.repo  https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo
yum install -y shadowsocks-libev
## 配置
cat > /etc/shadowsocks-libev/config.json << EOF
{
    "server":"0.0.0.0",
    "server_port":63007,
    "local_port":63008,
    "password":"123456",
    "timeout":60,
    "method":"chacha20-ietf-poly1305",
    "fast_open":true
}
EOF
## 启动服务
systemctl enable shadowsocks-libev
systemctl start shadowsocks-libev

```