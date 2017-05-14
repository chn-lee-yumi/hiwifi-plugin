module("luci.controller.admin_web.debian", package.seeall)

function index()
    local page = node("admin_web")
    page.target  = firstchild()
    page.title   = _("")
    page.order   = 9
    page.index = true
    entry({"debian"}, template("admin_web/debian"))
    entry({"debian","install_debian"}, call("install_debian"))
    entry({"debian","autostart"}, call("autostart"))
    entry({"debian","autostart_status"}, call("autostart_status"))
    entry({"debian","kod_start"}, call("kod_start"))
    entry({"debian","kod_stop"}, call("kod_stop"))
end

function install_debian()
    local return_info = luci.sys.exec(". /etc/market/TryDebian.script \&\& install_debian \&\& run_debian")
    luci.http.write(return_info)
end

function autostart()
    local return_info = luci.sys.exec(". /etc/market/TryDebian.script \&\& autostart")
    luci.http.write(return_info)
end

function autostart_status()
    local return_info = luci.sys.exec(". /etc/market/TryDebian.script \&\& autostart_status")
    luci.http.write(return_info)
end

function kod_start()
    local return_info = luci.sys.exec(". /etc/market/TryDebian.script \&\& kod_start")
    luci.http.write(return_info)
end

function kod_stop()
    local return_info = luci.sys.exec(". /etc/market/TryDebian.script \&\& kod_stop")
    luci.http.write(return_info)
end