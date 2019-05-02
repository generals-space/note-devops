# Jenkins应用(一) - Jenkins+Maven+GIT构建项目，及部署war包到远程tomcat

## 1. 环境准备

- 系统平台: Docker CentOS6镜像

- JDK: 1.8.0

- Tomcat: 8.5.4

- Jenkins版本: 2.7.1 war包版

首先配置JDK环境变量, 部署Jenkins到`tomcat/webapps`, 启动tomcat. **不建议使用root用启动**, 因为实验中root用户下运行的tomcat, jenkins响应特别慢, 下载插件也经常超时.

## 2. 基本设置

访问Jenkins主页, 可能需要一段时间准备.

Please wait while Jenkins is getting ready to work...

然后出现如下界面

![](https://gitee.com/generals-space/gitimg/raw/master/6a97f8404a44ce6160b2603324f05798.png)

首次访问Jenkins需要确认其已经正常启动(Jenkins在当前用户主目录创建了`.jenkins`目录). 从图中指定文件中取出这个值, 填写到输入框, 点击`continue`.

在一段等待之后, 会出现预装插件的选择界面. 这里有两个选项: 安装建议的插件, 选择要安装哪些插件. 为了能更清楚的认识Jenkins的工作流程, 这里选择第2项.

![](https://gitee.com/generals-space/gitimg/raw/master/8c4370b67cf1cf1303fd1994664e7d87.png)

然后在选择自定义插件的页面点击`none`, 然后`Install`...可能有点作死.

![](https://gitee.com/generals-space/gitimg/raw/master/56de6a5f8b0f4270f3eb51d871a0277e.png)

然后会出现创建用户的界面, 你需要为自己创建一个管理账户. 不建议点击`continue as admin`, 因为不知道admin的密码, 之后登陆的时候会出问题.

`Save and finish`->`Start using Jenkins`. 安装完成.

![](https://gitee.com/generals-space/gitimg/raw/master/1bde1fd97b40bfd272a31c0d481622b9.png)

## 3. 新建Job

Job, 即是一个流程, 指定从哪里或取源代码, 部署到哪一台目标机器. 以后每次开发人员发布新版本时, 执行一次这个流程, 就可以完成一次项目部署.

### 3.1 拉取源码

现在我们首先尝试使用Jenkins的Job从git系统上拉取下我们的工程代码.

点击Jenkins主页左侧`New Item(新建)`->`freestyle item(自由风格的软件项目)`, 在没有安装任何插件的时候, 选择新建Job只有这一种类型可以选择. 输入一个项目名称, 这里叫做`item1`, 点击OK确定.

然后进入Job的详细设置界面, 这里有`general`, `(源码管理)`, `(构建触发器)`, `(构建)`, 和`(构建后操作)`几项. 然而源码管理中选项只有一个`none`.

为此, 我们需要首先安装插件`SSH plugin`与`Git plugin`, 因为我们需要使用`ssh key`的方式对git服务器进行验证, 并且使用`git`命令从服务器pull源码. 所以我们还需要在Jenkins所在服务器上安装openssh与git.

回到Jenkins主页, 点击左侧`Manage Jenkins(系统管理)`->`Manage Plugins(管理插件)`, 目前在`Installed(已安装)`标签页中会看到这里是空的. 点击`Available(可选插件)`, 在右上角`filter`中可以输入过滤信息, 选择`SSH plugin`与`Git plugin`(后者依赖于前者), 点击下方`Install without restart(直接安装)`.

安装插件的时间可能有点长, 也有可能页面会无响应, 重启Jenkins可能没有用, 这时只能重启tomcat, 多试几次, 一些依赖插件(如LDAP)没有安装上没有关系的.

再次打开item1设置界面, 此时源码管理中将出现Git选项. 选择它之后需要在`Repository URL`字段指定git项目的地址, 最好将Jenkins(或者说Tomcat)的启动用户的SSH公钥拷贝到git服务器中, 并使用ssh类型的项目地址(一般会有https与ssh两种方式). 这种方式不需要再填写`Credentials`字段.

![](https://gitee.com/generals-space/gitimg/raw/master/a17fdc3a08a1e6f1bff37a1a2722f789.png)

> 注意此时系统中一定要已经安装sshd服务与git客户端.

保存设置, 回到项目主页, 在item1的项目主页左侧, 点击`(立即构建)`.

构建完成后, 在`~/.jenkins/workspace/item1`目录下面会出现项目的源码, 是Jenkins从git仓库下载下来的.

### 3.2 拉取后打包

Jenkins可以使用maven将源码打包(war形式)并部署到远程tomcat的webapp目录下, 条件是 **源码结构必需符合maven项目的结构标准** .

#### 3.2.1 安装maven

从官网下载maven包, 本示例中使用`apache-maven-3.3.9-bin.tar.gz`. 将其解压到`/usr/local`目录下, 并将`maven/bin/mvn`命令软件链接到`/usr/local/bin`目录或是将`maven/bin`目录加入环境变量中, 这里使用前者.

```
$ ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/local/bin/mvn
```

随后在Jenkins中配置maven的路径.

Jenkins主页->`系统管理`->`Global Tool Configuration`

Maven安装->`新增Maven`, 将自动安装取消勾选. 设置MAVEN_HOME的值, 保存即可.            

![](https://gitee.com/generals-space/gitimg/raw/master/729756c6f951aa38ae647be1f6bf0781.png)

然后安装Jenkins的maven插件`Maven Integration plugin`.

再次新建一个Job, 这时项目类型里会多出一个`构建一个Maven项目`的选项, 这里取名为item2, 点击OK. 其余配置如源码管理按照上一节所述, 保存即可.

点击`立即构建`.

Jenkins从git仓库下载完源码后, 会自行调用系统的maven工具打包, 第一次使用maven会从中央仓库下载很多文件, 可以在项目主页左侧的`Build History(构建历史)`中找到当前的构建流程, 点击进入会, 左侧有`Console Output`选项, 其中是本次构建的控制台输出.

![](https://gitee.com/generals-space/gitimg/raw/master/02e95ac1c6aecb18466fcac56a68d44e.png)

此次构建完成后, maven会在`~/.jenkins/workspace/item2`下生成一个`target`目录, 其中存放着git源码的war包文件.

```
$ pwd
/home/jenkins/.jenkins/workspace/item2
$ ls
pom.xml  src  target
$ ls target/
maven-archiver  web  web.war
```

### 3.3 部署到远程tomcat

部署war到远程tomcat, 首先要配置远程tomcat的IP, 并且要有对方tomcat的管理权限; 还要为maven指定打完包后的部署操作.

首先, 获得目标tomcat的管理权限. 需要其webapp下存在manager项目, 这样可以通过网页端的形式部署工程. 而它的管理员帐号配置, 在`tomcat/conf/tomcat-users.xml`文件中.

```xml
<tomcat-users>
<user username="admin" password="111111" roles="manager-gui,manager-script,manager-jmx,manager-status"/>
</tomcat-users>
```

可以尝试通过访问`http://localhost:8080/manager`, 用户名`admin`, 密码`111111`进行登录测试.

现在我们要求Jenkins在将源码打包后将war文件部署到目标tomcat. 为此我们需要安装`Deploy to container Plugin`插件.

安装完成后, 再次打开item2设置界面. 在页面底部`Post Build(构建后操作)`中增加构建完成后的操作步骤`Deploy war/ear to a container`, 点击`Add Container`添加目标tomcat.

首先指定上一步骤中生成的war包路径`WAR/EAR files`, 注意这里是以项目路径为根的相对路径, 取`target/web.war`.

`Context path`是通过何种路径访问目标工程, 比如`http://127.0.0.1:8080/context路径`

`Containers`是目标tomcat的地址, 包括管理员帐号和密码, 还有tomcat访问Url, 与上面tomcat管理帐户的配置相符即可.

![](https://gitee.com/generals-space/gitimg/raw/master/980da6192909c321657dc34d7b13e75f.png)

其他地方如`Pre Steps`, `Build`保持默认配置即可.

回到项目主页, 点击构建, 构建完成后远程tomcat的webapp目标下会出现名为item2的目录, 证明部署成功.

```
$ ls
docs  examples  host-manager  item2  item2.war  manager  ROOT
```

------

## 注意

`SSH plugin`插件需要系统中安装有`sshd`服务; `git plugin`连接git需要系统中安装`git`; 连接svn需要系统中安装`subversion`, 这些需要在安装插件之前安装.


## 推荐插件列表

- SSH Credentials Plugin:

- Subversion Plug-in: 提供连接SVN源码管理服务器的功能.

- Git plugin: Git源码管理

- SSH plugin: 提供SSH连接目标主机的方式

> 注意: 安装插件不需要重启Jenkins, 即时生效.