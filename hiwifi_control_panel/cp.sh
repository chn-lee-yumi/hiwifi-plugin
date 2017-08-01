#!/bin/sh

get_summary_info(){
    mem_total=$(cat /proc/meminfo|grep MemTotal|awk '{print $2}')
    cat /proc/meminfo > /tmp/cp_mem.tmp
    mem_free=$(cat /tmp/cp_mem.tmp|grep MemFree|awk '{print $2}')
    mem_free_2=$(awk 'BEGIN{printf "%.2f",'$mem_free'/'$mem_total'*100}')
    mem_buffers=$(cat /tmp/cp_mem.tmp|grep Buffers|awk '{print $2}')
    mem_buffers_2=$(awk 'BEGIN{printf "%.2f",'$mem_buffers'/'$mem_total'*100}')
    mem_cached=$(cat /tmp/cp_mem.tmp|grep Cached|head -n 1|awk '{print $2}')
    mem_cached_2=$(awk 'BEGIN{printf "%.2f",'$mem_cached'/'$mem_total'*100}')
    mem_used=$(awk 'BEGIN{print '$mem_total'-'$mem_free'-'$mem_buffers'-'$mem_cached'}')
    mem_used_2=$(awk 'BEGIN{printf "%.2f",'$mem_used'/'$mem_total'*100}')
    swap_total=$(cat /proc/meminfo|grep SwapTotal|awk '{print $2}')
    swap_free=$(cat /proc/meminfo|grep SwapFree|awk '{print $2}')
    swap_used=$(awk 'BEGIN{print '$swap_total'-'$swap_free'}')
    swap_used_2=$(awk 'BEGIN{printf "%.2f",'$swap_used'/'$swap_total'*100}')
    
    top -n 1|grep CPU: > /tmp/cp_cpu.tmp
    cpu_usr=$(cat /tmp/cp_cpu.tmp|awk '{print $2}'|sed 's/%//g')
    cpu_sys=$(cat /tmp/cp_cpu.tmp|awk '{print $4}'|sed 's/%//g')
    cpu_nic=$(cat /tmp/cp_cpu.tmp|awk '{print $6}'|sed 's/%//g')
    cpu_idle=$(cat /tmp/cp_cpu.tmp|awk '{print $8}'|sed 's/%//g')
    cpu_io=$(cat /tmp/cp_cpu.tmp|awk '{print $10}'|sed 's/%//g')
    cpu_irq=$(cat /tmp/cp_cpu.tmp|awk '{print $12}'|sed 's/%//g')
    cpu_sirq=$(cat /tmp/cp_cpu.tmp|awk '{print $14}'|sed 's/%//g')
    cpu_load=$(uptime|sed 's/.*age: //g')
    
    net_stat=$(ipstat --realtime)
    net_upload_speed=$(echo $net_stat|awk '{print $5}'|tr -cd "[0-9]"|awk '{printf "%.2f",$1/1024/8}')
    net_download_speed=$(echo $net_stat|awk '{printf "%.2f",$7/1024/8}')
    
    echo '{'\
        '"mem_total":"'$mem_total'",'\
        '"mem_free":"'$mem_free'",'\
        '"mem_free_2":"'$mem_free_2'",'\
        '"mem_used":"'$mem_used'",'\
        '"mem_used_2":"'$mem_used_2'",'\
        '"mem_buffers":"'$mem_buffers'",'\
        '"mem_buffers_2":"'$mem_buffers_2'",'\
        '"mem_cached":"'$mem_cached'",'\
        '"mem_cached_2":"'$mem_cached_2'",'\
        '"swap_total":"'$swap_total'",'\
        '"swap_used":"'$swap_used'",'\
        '"swap_used_2":"'$swap_used_2'",'\
        '"cpu_usr":"'$cpu_usr'",'\
        '"cpu_sys":"'$cpu_sys'",'\
        '"cpu_nic":"'$cpu_nic'",'\
        '"cpu_idle":"'$cpu_idle'",'\
        '"cpu_io":"'$cpu_io'",'\
        '"cpu_irq":"'$cpu_irq'",'\
        '"cpu_sirq":"'$cpu_sirq'",'\
        '"cpu_load":"'$cpu_load'",'\
        '"net_download_speed":"'$net_download_speed'",'\
        '"net_upload_speed":"'$net_upload_speed'",'\
        '"none":"none"'\
        '}'>/tmp/cp_summary_info.json
}

get_disk_info(){
    # 暂时这样写吧……
    is_mmc=$(df|grep mmcblk0)
    is_sda=$(df|grep sda)
    #is_cryptdata=$(df|grep cryptdata)
    if [ -n "$is_sda" ]; then
        disk_sda_size=$(df|grep sda|head -n 1|awk '{printf "%.2f",$2/1024/1024}')
        disk_sda_used=$(df|grep sda|head -n 1|awk '{printf "%.2f",$3/1024/1024}')
        disk_sda_used_2=$(awk 'BEGIN{printf "%.2f",'$disk_sda_used'/'$disk_sda_size'*100}')
        disk_sda_available=$(df|grep sda|head -n 1|awk '{printf "%.2f",$4/1024/1024}') # 单位：GB
        cat /proc/diskstats|grep sda|head -n 1 > /tmp/cp_disk1.tmp
        sleep 1
        cat /proc/diskstats|grep sda|head -n 1 > /tmp/cp_disk2.tmp
        disk_path="/dev/sda"
    elif [ -n "$is_mmc" ]; then
        disk_sda_size=$(df|grep mmcblk0|head -n 1|awk '{printf "%.2f",$2/1024/1024}')
        disk_sda_used=$(df|grep mmcblk0|head -n 1|awk '{printf "%.2f",$3/1024/1024}')
        disk_sda_used_2=$(awk 'BEGIN{printf "%.2f",'$disk_sda_used'/'$disk_sda_size'*100}')
        disk_sda_available=$(df|grep mmcblk0|head -n 1|awk '{printf "%.2f",$4/1024/1024}') # 单位：GB
        cat /proc/diskstats|grep mmcblk0|head -n 1 > /tmp/cp_disk1.tmp
        sleep 1
        cat /proc/diskstats|grep mmcblk0|head -n 1 > /tmp/cp_disk2.tmp
        disk_path="/dev/mmcblk0"
    else
        disk_path="没有发现存储设备"
        disk_sda_size=0
        disk_sda_used=0
        disk_sda_used_2=0
        disk_sda_available=0
        sleep 1
    fi
    sector_size=$(awk 'BEGIN{print 512/1024/1024}') # 扇区大小512B，换算成M。
    disk_read_var1=$(cat /tmp/cp_disk1.tmp|awk '{print $6}')
    disk_read_var2=$(cat /tmp/cp_disk2.tmp|awk '{print $6}')
    disk_read_speed=$(awk 'BEGIN{printf "%.2f",('$disk_read_var2'-'$disk_read_var1')*'$sector_size'/1}')
    disk_write_var1=$(cat /tmp/cp_disk1.tmp|awk '{print $10}')
    disk_write_var2=$(cat /tmp/cp_disk2.tmp|awk '{print $10}')
    disk_write_speed=$(awk 'BEGIN{printf "%.2f",('$disk_write_var2'-'$disk_write_var1')*'$sector_size'/1}') # 单位：MB/s
    if [ $disk_path = "没有发现存储设备" ]; then
        disk_read_speed=0
        disk_write_speed=0
    fi
    echo '{'\
        '"disk_path":"'$disk_path'",'\
        '"disk_sda_size":"'$disk_sda_size'",'\
        '"disk_sda_used":"'$disk_sda_used'",'\
        '"disk_sda_used_2":"'$disk_sda_used_2'",'\
        '"disk_sda_available":"'$disk_sda_available'",'\
        '"disk_read_speed":"'$disk_read_speed'",'\
        '"disk_write_speed":"'$disk_write_speed'",'\
        '"none":"none"'\
        '}'>/tmp/cp_disk_info.json
}

update_log(){
    lua /etc/market/cp-log.lua
}

while [ 1 ]
do
    get_summary_info
    get_disk_info
    update_log
done

