安装clamav杀毒软件并扫描
yum -install clamav -y
clamscan -r --bell -i 扫描的目录 -l 扫描结果存放文件

全系统扫描比较耗时，建议先扫描/usr  /bin  /etc/rc.d  /tmp

--remove 参数可以直接删除病毒文件

------

脚本文件不会报毒, 需要手动排查