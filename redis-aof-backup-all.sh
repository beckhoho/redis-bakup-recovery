#!/bin/sh
## 从库对所有实例备份
this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
parent_dir=`cd "$common_bin/../" >/dev/null; pwd`

for PORT in $@
do
$common_bin/redis_backup.sh ${PORT}
done
