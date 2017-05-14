#!/bin/sh

cache_path="/tmp"
cache_path2="/tmp/data"
# 读取备份的配置
. /root/CacheServer.conf
# 存储位置
if [ $cachepath == '1' ]; then
    cache_path_var1="内存"
    cache_path_var2=$cache_path
else
    cache_path_var1="外置存储"
    cache_path_var2=$cache_path2
fi
# 检查使用的空间大小
space_usage_var1=$(du $cache_path_var2/cache_server_cache/)
space_usage_var2=$(echo $space_usage_var1|cut -d " " -f 1)
let space_usage_var3=$space_usage_var2/1024
# 判断是否有超出限制范围，如果有，重启nginx。
if [ $space_usage_var3 -gt $cache_space_var3 ]; then
    echo $(date) $space_usage_var3 $cache_space_var3 >> /root/cache_server_error.log
    nginx -s reload
fi