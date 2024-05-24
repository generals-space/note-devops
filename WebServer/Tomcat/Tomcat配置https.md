# Tomcat配置https

参考文章

1. [完美配置Tomcat的HTTPS](http://blog.csdn.net/huaishuming/article/details/8965597)

## 1. JDK工具生成证书

**1. 生成key文件**

```log
[root@localhost conf]# keytool -genkey -alias tomcat -keyalg RSA -keystore ./tomcat.keystore
Enter keystore password:  
Re-enter new password: 
What is your first and last name?
  [Unknown]:  tomcat.generals.space
What is the name of your organizational unit?
  [Unknown]:  
What is the name of your organization?
  [Unknown]:  
What is the name of your City or Locality?
  [Unknown]:  
What is the name of your State or Province?
  [Unknown]:  
What is the two-letter country code for this unit?
  [Unknown]:  
Is CN=tomcat.generals.space, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown correct?
  [no]:  yes

Enter key password for <mykey>
	(RETURN if same as keystore password):  
Re-enter new password: 
```

**2. 生成证书文件**

```log
[root@localhost conf]# keytool -export -file ./tomcat.crt -alias tomcat -keystore ./tomcat.keystore 
Enter keystore password:  
Certificate stored in file <./tomcat.crt>
```

## 2. 修改tomcat配置

`server.xml`原配置如下

```xml
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/localhost-rsa.jks"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
```

```xml
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/tomcat.keystore"
                         certificateKeystorePassword="123456"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
```

## 3. FAQ

问题描述: 修改tomcat配置以后, 重启tomcat, 日志报错如下

```
java.lang.IllegalArgumentException: java.io.IOException: Alias name tomcat does not identify a key entry
```

原因分析: 在使用`keytool`命令创建`.keystore`文件时未指定`-alias`选项.

解决方法: 指定`-alias`选项重新生成`.keystore`文件, 再重启tomcat即可.
