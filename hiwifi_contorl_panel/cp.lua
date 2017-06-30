module("luci.controller.admin_web.cp", package.seeall)
local himsg = require 'himsg'
local cjson=require 'cjson'

function index()
    local page = node("admin_web")
    page.target  = firstchild()
    page.title   = _("")
    page.order   = 9
    page.index = true
    entry({"cp"}, template("admin_web/cp_main"))
    entry({"cp","main"}, template("admin_web/cp_main"))
    entry({"cp","get_summary_info"}, call("get_summary_info"))
    entry({"cp","get_disk_info"}, call("get_disk_info"))
    entry({"cp","monitor"}, template("admin_web/cp_monitor"))
    entry({"cp","get_top_text"}, call("get_top_text"))
    entry({"cp","get_df_h"}, call("get_df_h"))
    entry({"cp","get_diskstats"}, call("get_diskstats"))
    entry({"cp","get_fdisk_l"}, call("get_fdisk_l"))
    entry({"cp","tools"}, template("admin_web/cp_tools"))
    entry({"cp","function"}, template("admin_web/cp_function"))
    entry({"cp","update_log"}, call("update_log"))
    entry({"cp","update_res"}, call("update_res"))
    entry({"cp","samba_opt_switch"}, call("samba_opt_switch"))
    entry({"cp","samba_opt_status"}, call("samba_opt_status"))
    entry({"cp","get_storage_info"}, call("get_storage_info"))
    entry({"cp","mem_opt_switch"}, call("mem_opt_switch"))
    entry({"cp","mem_opt_status"}, call("mem_opt_status"))
    entry({"cp","ping_opt_switch"}, call("ping_opt_switch"))
    entry({"cp","ping_opt_status"}, call("ping_opt_status"))
    
end

function get_summary_info()
    local summary_info = luci.sys.exec("cat /tmp/cp_summary_info.json")
    luci.http.write(summary_info)
end

function get_disk_info()
    local disk_info = luci.sys.exec("cat /tmp/cp_disk_info.json")
    luci.http.write(disk_info)
end

function get_top_text()
    local top_text = luci.sys.exec("top -b -n 1 | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write(top_text)
end

function get_df_h()
    local df_h = luci.sys.exec("df -h | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write('<p style="font-family:黑体">'..df_h..'</p>')
end

function get_diskstats()
    local diskstats = luci.sys.exec("cat /proc/diskstats | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write('<p style="font-family:黑体">'..diskstats..'</p>')
end

function get_fdisk_l()
    local fdisk_l = luci.sys.exec("fdisk -l | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write('<p style="font-family:黑体">'..fdisk_l..'</p>')
end

function update_log()
    local log_text = luci.sys.exec("cat /tmp/cp_log.json")
    luci.http.write(log_text)
end

function update_res()
    luci.sys.exec(". /etc/market/cp2.sh \&\& update_res")
    luci.http.write('更新程序执行完毕！请关闭此页面，在控制面板页面刷新即可。')
end

function samba_opt_switch()
    luci.sys.exec(". /etc/market/cp2.sh \&\& samba_opt_switch")
end

function samba_opt_status()
    local samba_opt_status_1 = luci.sys.exec(". /etc/market/cp2.sh \&\& samba_opt_status")
    luci.http.write(samba_opt_status_1)
end

function get_storage_info()
    local storage_info = himsg.call('service.storaged', 'list', '');
    luci.http.write('<p style="font-family:黑体">'..storage_info.data..'</p>')
end

function mem_opt_switch()
    luci.sys.exec(". /etc/market/cp2.sh \&\& mem_opt_switch")
end

function mem_opt_status()
    local samba_opt_status_1 = luci.sys.exec(". /etc/market/cp2.sh \&\& mem_opt_status")
    luci.http.write(samba_opt_status_1)
end

function ping_opt_switch()
    luci.sys.exec(". /etc/market/cp2.sh \&\& ping_opt_switch")
end

function ping_opt_status()
    local samba_opt_status_1 = luci.sys.exec(". /etc/market/cp2.sh \&\& ping_opt_status")
    luci.http.write(samba_opt_status_1)
end