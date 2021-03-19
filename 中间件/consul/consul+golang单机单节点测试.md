
参考文章

1. [consul官方文档 - Web UI](https://learn.hashicorp.com/consul/getting-started/ui.html)

2. [consul dockerhub文档 [Running Consul for Development]小节](https://hub.docker.com/_/consul/)

3. [golang使用服务发现系统consul](https://blog.csdn.net/changjixiong/article/details/74838182)

```
docker run -d --name devconsul -p 8500:8500 consul agent -dev -ui -client=0.0.0.0
```

`-dev`: 开发模式运行, 不同于`server`与`client`模式, 不需要join(不过开发模式下其实也可以join, 见参考文章2)

`-ui`: 启动Web UI

`-client`: http接口绑定的地址. 默认为127.0.0.1, 在docker容器不无法被宿主机访问到.

------

查看leader节点

```
$ curl localhost:8500/v1/status/leader
"127.0.0.1:8300"
```

设置KV

```
$ curl -X PUT --data 'hello consul' localhost:8500/v1/kv/foo
true
$ curl localhost:8500/v1/kv/foo
[
    {
        "LockIndex": 0,
        "Key": "foo",
        "Flags": 0,
        "Value": "aGVsbG8gY29uc3Vs",
        "CreateIndex": 31,
        "ModifyIndex": 31
    }
]
```

...`Value`是加密后的?

直接在命令行查询好了.

```
$ docker exec -t devconsul consul kv get foo
hello consul
```

## 服务注册与发现并调用

参考文章3提供了使用consul进行服务注册与发现的示例代码, 但是ta把健康检查放在了单独的端口, 而且订阅者与服务提供者是通过tcp连接, 感觉不容易理解.

先启动服务端, 再启动客户端, 客户端循环向consul获取指定服务的地址并请求. 

当服务端停止后, 客户端先是会出现`connection refused`, 因为此时consul只是知道服务端健康检查失败, 需要一个试错的时间, 再然后consul确定服务端已经不存在后删除其服务, 客户端就会出现`service not found`结果.

### 服务端

```go
package main

import (
	"fmt"
	"log"
	"net/http"

	consulapi "github.com/hashicorp/consul/api"
)

const (
	serviceAddr = "192.168.0.8" // service服务所在IP地址, 注意: 必须要让consul所在节点能够连接到, 否则健康检查不会成功
	servicePort = 8080
	checkPath   = "/check"
	servicePath = "/greet"

	serviceID   = "serverNode_1" // 唯一
	serviceName = "serverNode"
)

// healthCheckHandler consul健康检查接口
func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "health check")
}

// serviceHandler 业务接口
func serviceHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "hello client!")
}

func registerServer() {
	// 默认consul连接地址为127.0.0.1:8500
	config := consulapi.DefaultConfig()
	client, err := consulapi.NewClient(config)
	if err != nil {
		log.Fatal("consul client error : ", err)
	}

	registration := &consulapi.AgentServiceRegistration{
		ID:      serviceID,
		Name:    serviceName,
		Address: serviceAddr,
		Port:    servicePort,
		Tags:    []string{"serverNode"},
	}

	checkAddr := fmt.Sprintf("http://%s:%d%s", serviceAddr, servicePort, checkPath)
	registration.Check = &consulapi.AgentServiceCheck{
		HTTP:                           checkAddr,
		Timeout:                        "3s",
		Interval:                       "5s",
		DeregisterCriticalServiceAfter: "30s", //check失败后30秒删除本服务
	}
	err = client.Agent().ServiceRegister(registration)
	if err != nil {
		log.Fatal("register server error : ", err)
	}
}

func main() {
	log.Println("regist start")
	go registerServer()
	log.Println("regist complete")
	http.HandleFunc(checkPath, healthCheckHandler)
	http.HandleFunc(servicePath, serviceHandler)

	log.Println("start http server")
	http.ListenAndServe(fmt.Sprintf("%s:%d", serviceAddr, servicePort), nil)
}

```

### 客户端

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	consulapi "github.com/hashicorp/consul/api"
)

const (
	serviceAddr = "192.168.0.8" // service服务所在IP地址, 注意: 必须要让consul所在节点能够连接到, 否则健康检查不会成功
	servicePort = 8080
	checkPath   = "/check"
	servicePath = "/greet"

	serviceID   = "serverNode_1" // 唯一
	serviceName = "serverNode"
)

func main() {
	// 默认consul连接地址为127.0.0.1:8500
	config := consulapi.DefaultConfig()
	client, err := consulapi.NewClient(config)
	if err != nil {
		log.Fatal("consul client error : ", err)
	}

	for {
		time.Sleep(time.Second * 3)
		services, err := client.Agent().Services()

		if nil != err {
			log.Println("in consual list Services:", err)
			continue
		}

		if _, found := services[serviceID]; !found {
			log.Printf("service %s not found", serviceID)
			continue
		}
		serviceObj := services[serviceID]
		serviceURL := fmt.Sprintf("http://%s:%d%s", serviceObj.Address, serviceObj.Port, servicePath)
		log.Println("request service: ", serviceID)
		res, err := http.Get(serviceURL)
		if err != nil {
			log.Println("request service failed: ", err.Error())
			continue
		}
		defer res.Body.Close()
		bodyCnt := make([]byte, 1024)
		length, _ := res.Body.Read(bodyCnt)
		log.Println("request service response: ", string(bodyCnt[:length]))
	}
}

```