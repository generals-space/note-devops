yum install -y git

################################################################ 
## docker-ce
# step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
yum makecache fast
yum -y install docker-ce
# Step 4: 开启Docker服务
systemctl start docker
systemctl enable docker
## docker-ce end...
################################################################ 
## golang
GO_VERSION=1.12.17
curl -o /usr/local/go${GO_VERSION}.tar.gz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
cd /usr/local
tar -zxf go${GO_VERSION}.tar.gz && rm -f go${GO_VERSION}.tar.gz
cd
echo 'PATH=$PATH:/usr/local/go/bin' >> /etc/profile
source /etc/profile
## golang end...
################################################################ 
