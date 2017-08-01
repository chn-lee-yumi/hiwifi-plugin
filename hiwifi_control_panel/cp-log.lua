--[[
读取cp.sh输出的文件（/tmp/cp_summary_info.json /tmp/cp_disk_info.json）和上一次的历史记录（/tmp/cp_log.json）。
从中得到：cpu使用率、内存使用量、swap使用量、磁盘读写速度、网速  这五个数据，并更新历史记录。
历史记录为echarts能读取的json格式，历史记录时长2分钟，即有61组数据。
数据呈现为四个折线图。
json文件保存在：/tmp/cp_log.json
--]]

require("socket")
function sleep(n)
   socket.select(nil, nil, n)
end

local cjson = require "cjson"

--读取cp.sh输出的文件（/tmp/cp_summary_info.json /tmp/cp_disk_info.json）和上一次的历史记录（/tmp/cp_log.json）。
file_summary_info=io.open("/tmp/cp_summary_info.json","r")
file_disk_info=io.open("/tmp/cp_disk_info.json","r")
file_log_json_1=io.open("/tmp/cp_log.json","r")
summary_info=file_summary_info:read("*all")
disk_info=file_disk_info:read("*all")
log_json_1=file_log_json_1:read("*all")
file_summary_info:close()
file_disk_info:close()
file_log_json_1:close()
--从中得到：cpu使用率、内存使用量、swap使用量、磁盘读写速度、网速  这五个数据，并更新历史记录。
summary_json=cjson.decode(summary_info)
disk_json=cjson.decode(disk_info)
log_json_1=cjson.decode(log_json_1)
for i=1,60 do
    log_json_1["cpu_usage_log"][i]=log_json_1["cpu_usage_log"][i+1]
    log_json_1["mem_usage_log"][i]=log_json_1["mem_usage_log"][i+1]
    log_json_1["swap_usage_log"][i]=log_json_1["swap_usage_log"][i+1]
    log_json_1["disk_read_log"][i]=log_json_1["disk_read_log"][i+1]
    log_json_1["disk_write_log"][i]=log_json_1["disk_write_log"][i+1]
    log_json_1["net_upload_log"][i]=log_json_1["net_upload_log"][i+1]
    log_json_1["net_download_log"][i]=log_json_1["net_download_log"][i+1]
end
log_json_1["cpu_usage_log"][61]=100-summary_json["cpu_idle"]
log_json_1["mem_usage_log"][61]=summary_json["mem_used"]
log_json_1["swap_usage_log"][61]=summary_json["swap_used"]
log_json_1["disk_read_log"][61]=disk_json["disk_read_speed"]
log_json_1["disk_write_log"][61]=disk_json["disk_write_speed"]
log_json_1["net_upload_log"][61]=summary_json["net_upload_speed"]
log_json_1["net_download_log"][61]=summary_json["net_download_speed"]
--json文件保存在：/tmp/cp_log.json
local log_json_2=cjson.encode(log_json_1)
file_log=io.open("/tmp/cp_log.json","w")
file_log:write(log_json_2)
file_log:close()
sleep(0.6)