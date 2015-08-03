#!/bin/sh
## 主库每小时给每个实例做一次快照(bgsave)
## 拷贝每个实例的dump转储文件到其他目录并对其打包
## 压缩包要有异地备份
## 之后再做一次快照(bgsave)


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
LOGFILE=${bak}/redis_dump_bakup_$CURDATE.log

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

##备份DUMP文件
cd $RDIR
tar -zcf $DDIR/${PORT}_dump_${CURTIME}.tar.gz dump-${PORT}.rdb
if test $? != 0 ; then
        echo “tar error dump-${PORT}.rdb” >> $LOGFILE
        #exit 1
fi

##
sleep 5
##

## 快照(bgsave)
redis-cli -h 127.0.0.1 -p $PORT bgsave

##
sleep 10
##

##删除旧备份
#/bin/rm -rf `date -d -7day +”%Y%m%d”`
find $bak -mtime +7 | xargs rm -rf
echo “Backup dump ${PORT} ok at $CURTIME !” >> $LOGFILE
