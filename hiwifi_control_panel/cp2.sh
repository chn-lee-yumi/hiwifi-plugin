#!/bin/sh

mem_opt_path=/etc/rc.d/S99cp_mem_opt
ping_opt_path=/etc/rc.d/S99cp_ping_opt
samba_opt_path=/etc/rc.d/S99cp_samba_opt

samba_opt_on(){
    sed -i 's/SO_RCVBUF=[0-9]*/SO_RCVBUF=655360/g' /etc/samba/smb.conf.template
    sed -i 's/SO_SNDBUF=[0-9]*/SO_SNDBUF=655360/g' /etc/samba/smb.conf.template
    /etc/init.d/samba reload
    (
    cat <<EOF
#!/bin/sh /etc/rc.common

START=99

start(){
    sed -i 's/SO_RCVBUF=[0-9]*/SO_RCVBUF=655360/g' /etc/samba/smb.conf.template
    sed -i 's/SO_SNDBUF=[0-9]*/SO_SNDBUF=655360/g' /etc/samba/smb.conf.template
    /etc/init.d/samba reload
}
EOF
    ) > $samba_opt_path
    chmod 777 $samba_opt_path
}

samba_opt_off(){
    sed -i 's/SO_RCVBUF=[0-9]*/SO_RCVBUF=65535/g' /etc/samba/smb.conf.template
    sed -i 's/SO_SNDBUF=[0-9]*/SO_SNDBUF=65535/g' /etc/samba/smb.conf.template
    /etc/init.d/samba reload
    rm $samba_opt_path
}

samba_opt_status(){
    status_1=$(cat /var/etc/smb.conf | grep "SO_RCVBUF=655360 SO_SNDBUF=655360" | wc -l)
    if [ $status_1 -ge "1" ]; then
        echo "打开"
    else
        echo "关闭"
    fi
}

samba_opt_switch(){
    if [ $(samba_opt_status) = "打开" ]; then
        samba_opt_off
    else
        samba_opt_on
    fi
    echo $(samba_opt_status)
}

mem_opt_on(){
    echo 2048 > /proc/sys/vm/min_free_kbytes
    echo 50 > /proc/sys/vm/vfs_cache_pressure
    (
    cat <<EOF
#!/bin/sh /etc/rc.common

START=99

start(){
    (sleep 10; echo 2048 > /proc/sys/vm/min_free_kbytes)&
    echo 50 > /proc/sys/vm/vfs_cache_pressure
}
EOF
    ) > $mem_opt_path
    chmod 777 $mem_opt_path
}

mem_opt_off(){
    rm $mem_opt_path
    echo 4096 > /proc/sys/vm/min_free_kbytes
    echo 200 > /proc/sys/vm/vfs_cache_pressure
}

mem_opt_status(){
    status_1=$(cat /proc/sys/vm/min_free_kbytes)
    if [ $status_1 -le "2048" ]; then
        echo "打开"
    else
        echo "关闭"
    fi
}

mem_opt_switch(){
    if [ $(mem_opt_status) = "打开" ]; then
        mem_opt_off
    else
        mem_opt_on
    fi
    echo $(mem_opt_status)
}

ping_opt_on(){
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
    (
    cat <<EOF
#!/bin/sh /etc/rc.common

START=99

start(){
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
}
EOF
    ) > $ping_opt_path
    chmod 777 $ping_opt_path
}

ping_opt_off(){
    rm $ping_opt_path
    echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
}

ping_opt_status(){
    status_1=$(cat /proc/sys/net/ipv4/icmp_echo_ignore_all)
    if [ $status_1 -eq "1" ]; then
        echo "打开"
    else
        echo "关闭"
    fi
}

ping_opt_switch(){
    if [ $(ping_opt_status) = "打开" ]; then
        ping_opt_off
    else
        ping_opt_on
    fi
    echo $(ping_opt_status)
}


controller_path=/usr/lib/lua/luci/controller/admin_web/cp.lua
view_cp_main_path=/usr/lib/lua/luci/view/admin_web/cp_main.htm
view_cp_monitor_path=/usr/lib/lua/luci/view/admin_web/cp_monitor.htm
view_cp_tools_path=/usr/lib/lua/luci/view/admin_web/cp_tools.htm
view_cp_function_path=/usr/lib/lua/luci/view/admin_web/cp_function.htm
sh_path=/etc/market/cp.sh
sh2_path=/etc/market/cp2.sh
sh_log_path=/etc/market/cp-log.lua
daemon_path=/etc/init.d/hiwifi_control_panel

update_res(){
    stop
    rm $controller_path
    rm $view_cp_main_path
    rm $view_cp_monitor_path
    rm $view_cp_tools_path
    rm $view_cp_function_path
    rm $sh_path
    rm $sh2_path
    rm $sh_log_path
    rm $daemon_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp_main.htm -O $view_cp_main_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp_monitor.htm -O $view_cp_monitor_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp_tools.htm -O $view_cp_tools_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp_function.htm -O $view_cp_function_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp.lua -O $controller_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp.sh -O $sh_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp2.sh -O $sh2_path
    wget http://139.129.20.107/hiwifi_contorl_panel/cp-log.lua -O $sh_log_path
    wget http://139.129.20.107/hiwifi_contorl_panel/hiwifi_control_panel -O $daemon_path
    chmod +x $daemon_path
    rm /var/run/luci-indexcache
    start
}

install_cp(){
    cp hiwifi_control_panel /etc/init.d
    chmod +x /etc/init.d/hiwifi_control_panel
    cp cp.lua $controller_path
    cp cp_main.htm $view_cp_main_path
    cp cp_monitor.htm $view_cp_monitor_path
    cp cp_tools.htm $view_cp_tools_path
    cp cp_function.htm $view_cp_function_path
    cp cp.sh $sh_path
    cp cp2.sh $sh2_path
    cp cp-log.lua $sh_log_path
    cp -r cp /www
    rm /var/run/luci-indexcache
    start
    # sed -i 's/<span class="ft-nav">/<span class="ft-nav"><a href="..\/cp\/main" target="_blank">服务器控制面板<\/a><span>\&nbsp;\&nbsp;<\/span>\|<span>\&nbsp;\&nbsp;<\/span>/g' /usr/lib/lua/luci/view/admin_web/footer.htm
    echo $mem_opt_path >> /lib/upgrade/keep.d/hiwifi_control_panel
    echo $ping_opt_path >> /lib/upgrade/keep.d/hiwifi_control_panel
    echo $samba_opt_path >> /lib/upgrade/keep.d/hiwifi_control_panel
}

uninstall_cp(){
    stop
    rm $controller_path
    rm $view_cp_main_path
    rm $view_cp_monitor_path
    rm $view_cp_tools_path
    rm $view_cp_function_path
    rm $sh_path
    rm $sh2_path
    rm $sh_log_path
    rm $daemon_path
    rm -rf /www/cp
    # sed -i 's/<span class="ft-nav"><a href="..\/cp\/main" target="_blank">服务器控制面板<\/a><span>\&nbsp;\&nbsp;<\/span>|<span>\&nbsp;\&nbsp;<\/span>/<span class="ft-nav">/g' /usr/lib/lua/luci/view/admin_web/footer.htm
    return 0
}

start_cp() {
    # 开始记录状态历史
    /etc/init.d/hiwifi_control_panel start
    /etc/init.d/hiwifi_control_panel enable
	return 0
}

stop_cp() {
    # 停止记录状态历史
    /etc/init.d/hiwifi_control_panel stop
    /etc/init.d/hiwifi_control_panel disable
	return 0
}

status_cp(){
    lan_ip=$(ifconfig br-lan|grep 'inet addr'|awk '{print $2}'|tr -d 'addr:')
    if [ $(ps|grep 'cp.sh'|wc -l) -ge "2" ]; then
        echo '{ "status" : "running", "msg" : "监控功能已启动。<br>点击打开控制面板： <a href=\"http://'$lan_ip'/cgi-bin/turbo/cp/main\" target=\"_blank\">http://'$lan_ip'/cgi-bin/turbo/cp/main</a>" }'
    else
        echo '{ "status" : "stopped", "msg" : "监控功能未启动。<br>点击打开控制面板： <a href=\"http://'$lan_ip'/cgi-bin/turbo/cp/main\" target=\"_blank\">http://'$lan_ip'/cgi-bin/turbo/cp/main</a>" }'
    fi
}
