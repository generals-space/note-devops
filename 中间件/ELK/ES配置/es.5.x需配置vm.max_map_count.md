# es.5.x需配置vm.max_map_count

否则启动失败, 报错如下

```
[2021-11-10T11:29:02,359][INFO ][o.e.p.PluginsService     ] [es-1110-b-master-0] loaded plugin [x-pack]
[2021-11-10T11:29:07,149][DEBUG][o.e.a.ActionModule       ] Using REST wrapper from plugin org.elasticsearch.xpack.XPackPlugin
[2021-11-10T11:29:10,542][INFO ][o.e.x.m.j.p.l.CppLogMessageHandler] [controller/74] [Main.cc@128] controller (64 bit): Version 5.5.0 (Build 9352b273163d45) Copyright (c) 2017 Elasticsearch BV
[2021-11-10T11:29:10,640][INFO ][o.e.d.DiscoveryModule    ] [es-1110-b-master-0] using discovery type [zen]
[2021-11-10T11:29:12,654][INFO ][o.e.n.Node               ] [es-1110-b-master-0] initialized
[2021-11-10T11:29:12,654][INFO ][o.e.n.Node               ] [es-1110-b-master-0] starting ...
[2021-11-10T11:29:13,461][INFO ][o.e.t.TransportService   ] [es-1110-b-master-0] publish_address {192.168.34.43:9311}, bound_addresses {192.168.34.43:9311}
[2021-11-10T11:29:13,540][INFO ][o.e.b.BootstrapChecks    ] [es-1110-b-master-0] bound or publishing to a non-loopback or non-link-local address, enforcing bootstrap checks
ERROR: [1] bootstrap checks failed
[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
[2021-11-10T11:29:13,550][INFO ][o.e.n.Node               ] [es-1110-b-master-0] stopping ...
[2021-11-10T11:29:13,642][INFO ][o.e.n.Node               ] [es-1110-b-master-0] stopped
[2021-11-10T11:29:13,642][INFO ][o.e.n.Node               ] [es-1110-b-master-0] closing ...
[2021-11-10T11:29:13,656][INFO ][o.e.n.Node               ] [es-1110-b-master-0] closed
```
