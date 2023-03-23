# es-启动失败main ERROR Could not register mbeans java.security.AccessControlException: access denied (javax.management.MBeanTrustPermission register)[jvm.options]

参考文章

1. [Elasticsearch starts with security manager exceptions](https://github.com/elastic/elasticsearch/issues/21932)
    - 官方issue

elasticsearch: v5.5.0

在启动时, 报错如下

```log
2016-12-02 11:23:11,825 main ERROR Could not register mbeans java.security.AccessControlException: access denied ("javax.management.MBeanTrustPermission" "register")
    at java.security.AccessControlContext.checkPermission(AccessControlContext.java:472)
    at java.lang.SecurityManager.checkPermission(SecurityManager.java:585)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.checkMBeanTrustPermission(DefaultMBeanServerInterceptor.java:1848)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.registerMBean(DefaultMBeanServerInterceptor.java:322)
    at com.sun.jmx.mbeanserver.JmxMBeanServer.registerMBean(JmxMBeanServer.java:522)
    at org.apache.logging.log4j.core.jmx.Server.register(Server.java:390)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:167)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:140)
    at org.apache.logging.log4j.core.LoggerContext.setConfiguration(LoggerContext.java:507)
    at org.apache.logging.log4j.core.LoggerContext.start(LoggerContext.java:249)
    at org.apache.logging.log4j.core.impl.Log4jContextFactory.getContext(Log4jContextFactory.java:206)
    at org.apache.logging.log4j.core.config.Configurator.initialize(Configurator.java:219)
    at org.apache.logging.log4j.core.config.Configurator.initialize(Configurator.java:196)
    at org.elasticsearch.common.logging.LogConfigurator.configureStatusLogger(LogConfigurator.java:125)
    at org.elasticsearch.common.logging.LogConfigurator.configureWithoutConfig(LogConfigurator.java:67)
    at org.elasticsearch.cli.Command.main(Command.java:59)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:89)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:82)

2016-12-02 11:23:12,121 main ERROR Could not register mbeans java.security.AccessControlException: access denied ("javax.management.MBeanTrustPermission" "register")
    at java.security.AccessControlContext.checkPermission(AccessControlContext.java:472)
    at java.lang.SecurityManager.checkPermission(SecurityManager.java:585)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.checkMBeanTrustPermission(DefaultMBeanServerInterceptor.java:1848)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.registerMBean(DefaultMBeanServerInterceptor.java:322)
    at com.sun.jmx.mbeanserver.JmxMBeanServer.registerMBean(JmxMBeanServer.java:522)
    at org.apache.logging.log4j.core.jmx.Server.register(Server.java:390)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:167)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:140)
    at org.apache.logging.log4j.core.LoggerContext.setConfiguration(LoggerContext.java:507)
    at org.apache.logging.log4j.core.LoggerContext.start(LoggerContext.java:249)
    at org.elasticsearch.common.logging.LogConfigurator.configure(LogConfigurator.java:116)
    at org.elasticsearch.common.logging.LogConfigurator.configure(LogConfigurator.java:83)
    at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:254)
    at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:121)
    at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:112)
    at org.elasticsearch.cli.SettingCommand.execute(SettingCommand.java:54)
    at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:96)
    at org.elasticsearch.cli.Command.main(Command.java:62)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:89)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:82)

Exception: java.security.AccessControlException thrown from the UncaughtExceptionHandler in thread "Thread-2"
```

参考文章1所说, 是因为 jvm.options 中缺少了`-Dlog4j2.disable.jmx=true`的配置.

排查之后果然如此, 是因为根本没拷贝`jvm.options`到`$ES/config`目录中, 拷贝过去后就可以了.
