#!/bin/bash
## 主库挂了（redis程序挂了/机器宕机了）
## 从库正常
## 恢复到主库挂掉的时间点：去从库手动做一次快照，拷贝快照到主库相应目录
#REDISPASSWORD=My#redis

# 在从节点做一次快照
for PORT in $@
do
	redis-cli -h 127.0.0.1 -p $PORT bgsave
	sleep 5
done
##
sleep 10
##

# 拷贝快照
for PORT in $@
do
	#将从库快照拷贝到主库目录
	#sleep 1
done

