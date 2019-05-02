# FastDFS错误处理

## 1. 

参考文章

[FastDFS常见问题](http://support.supermap.com.cn/DataWarehouse/WebDocHelp/6.1.3/iserverOnlineHelp/Server_Service_Management/CacheConfig/FastDFS_install_config/FastDFSFAQ.htm)

```
2016-12-16 10:43:07,731 ERROR [FastDfsService][2016121610430000000790095] - fastDfs上传错误
org.csource.common.MyException: getStoreStorage fail, errno code: 28
        at org.csource.fastdfs.StorageClient.newWritableStorageConnection(StorageClient.java:1941)
```

问题描述

服务器端工程使用Java作为连接FastDFS的语言, 正常使用一段时间后, 上传文件时项目报上述错误.

然而使用FastDFS自带的命令行工具是可以正常上传的.

```
$ fdfs_upload_file /etc/fdfs/client.conf ./Shell_Scripting.pdf 10.19.55.36:24000
group1/M00/00/0A/ChM3JFhTV4-AArkkAED_J_EZ7Qo039.pdf
```

原因分析

错误代码28表示**No space left on device**。FastDFS可在tracker.conf配置文件中设置 `reserved_storage_sapce` 参数，即storage的预留存储空间大小，默认为10%。如果预留空间小于该设置值，将出现28错误。