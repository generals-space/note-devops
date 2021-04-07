#!/bin/bash
## root 的 crontab 配置
## */2 * * * * cd /Users/general/.ssh; /bin/bash flush_dns.sh

date >> /Users/general/.ssh/cron.log 2>&1
sudo killall -HUP mDNSResponder >> /Users/general/.ssh/cron.log 2>&1
sudo killall mDNSResponderHelper >> /Users/general/.ssh/cron.log 2>&1
sudo dscacheutil -flushcache >> /Users/general/.ssh/cron.log 2>&1
