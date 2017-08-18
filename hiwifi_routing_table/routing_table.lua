module("luci.controller.admin_web.routing_table", package.seeall)

function index()
    local page = node("admin_web")
    page.target  = firstchild()
    page.title   = _("")
    page.order   = 9
    page.index = true
    entry({"routing_table"}, template("admin_web/routing_table"))
    entry({"routing_table","show_ip_route"}, call("show_ip_route"))
    entry({"routing_table","show_int"}, call("show_int"))
    entry({"routing_table","set_routing_tabel"}, call("set_routing_tabel"))
end

function show_ip_route()
    local return_info = luci.sys.exec("route | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write(return_info)
end

function show_int()
    local return_info = luci.sys.exec("ifconfig | sed ':a;N;$!ba;s/\\n/<br>/g' | sed 's/[ ]/\\&nbsp;/g'")
    luci.http.write(return_info)
end

function set_routing_tabel()
    cmd="route"..' '..luci.http.formvalue("act")..' '..luci.http.formvalue("tgt")..' '..luci.http.formvalue("ip")..' '..luci.http.formvalue("next")..' '..luci.http.formvalue("next_hop")
    local return_info = luci.sys.exec(cmd)
    luci.http.write('<body onload=\'javascript:window.location.href="http://hiwifi.lan/cgi-bin/turbo/routing_table";\'>')
end