#!/bin/sh
## 从库每天/每小时（根据数据安全性要求）备份每个实例的AOF
## 压缩AOF文件，传至备份服务器或是HDFS
## 重写AOF文



this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
parent_dir=`cd "$common_bin/../" >/dev/null; pwd`
bak=`cd "$common_bin/../bak" >/dev/null; pwd`

CURDATE=`date +%Y%m%d`
CURHOUR=`date +%Y%m%d_%H`
CURTIME=`date +%Y%m%d_%H%M%S`
REDISPASSWORD=My#redis
#IP=$1
PORT=$1
LOGFILE=${bak}/redis_aof_bakup_$CURDATE.log

DDIR=$bak/$CURHOUR
mkdir -p $DDIR
RDIR=$parent_dir/$PORT

## print usage
if test $# -ne 1 ; then
	echo “Usage:$0 port”
	exit
fi

##error case
if test "$PORT" = "" ; then
	echo “Port Error!”
	exit 1
else
	if test ! -d "$RDIR" ; then
		echo “redis data Error!”
		exit 1
	fi
fi

##备份AOF文件
cd $RDIR
tar -zcf $DDIR/${PORT}_aof_${CURTIME}.tar.gz appendonly-${PORT}.aof
if test $? != 0 ; then
	echo “tar error appendonly-${PORT}.aof” >> $LOGFILE
	#exit 1
fi

##
sleep 5
##

##调用BGREWRITEAOF重写AOF文件，AOF在重写的时候会占大量的CPU和内存和资源
#redis-cli -h 127.0.0.1 -c -p $PORT -a $REDISPASSWORD bgrewriteaof
redis-cli -h 127.0.0.1 -c -p $PORT bgrewriteaof

##
sleep 5
##

##删除旧备份
#/bin/rm -rf `date -d -7day +”%Y%m%d”`
find $bak -mtime +7 | xargs rm -rf
echo “Backup aof ${PORT} ok at $CURTIME !” >> $LOGFILE

