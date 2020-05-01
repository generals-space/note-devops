## vpn服务适用于一些开源项目的编译工作, 有时无法走ss/proxy等代理的场景.
yum install -y ppp pptp pptp-setup
modprobe nf_conntrack_pptp

pptpsetup --create general --server ss.generals.space --username general --password 123456 --encrypt

## pptpsetup 会在 /etc/ppp/peers 目录下创建名为 general 的配置文件.

## $ cat /etc/ppp/peers/general
## # written by pptpsetup
## pty "pptp ss.generals.space --nolaunchpppd"
## lock
## noauth
## nobsdcomp
## nodeflate
## name general
## remotename general
## ipparam general
## require-mppe-128

## pptpsetup 还会修改 /etc/ppp/chap-secrets 文件, 写入如下内容
## # added by pptpsetup for general
## general general "123456" *

ppp_doc_dir_name=$(ls /usr/share/doc/ | grep ppp)
ppp_doc_dir=/usr/share/doc/${ppp_doc_dir_name}

cp ${ppp_doc_dir}/scripts/poff /usr/sbin/
cp ${ppp_doc_dir}/scripts/pon /usr/sbin/
chmod +x /usr/sbin/pon /usr/sbin/poff

#################################################
## 示例操作
## 连接
# pon general
## 断开VPN
# poff 
## 添加默认路由路由
# route add -net 0.0.0.0 dev ppp0 
