# Redis-表结构设计(键值设计)

参考文章

1. [浅谈 Redis 数据库的键值设计](https://www.oschina.net/question/12_27517)
    - 介绍了用户登录系统, Tag系统两种表在关系型数据库与redis中的设计思路
    - redis的列表, 集合在实际场景中的作用

redis键名一般使用冒号做分割符, 这是不成文的规矩.
