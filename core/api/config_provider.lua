local json = require("cjson")
local dbUtils = require "flux_gate/core/utils/db_utils"

local function fetchConfig()
    local db = dbUtils.connect()
    return dbUtils.fetchConfig(db)
end


local method = ngx.req.get_method()
if method == "GET" then
    local json_string = fetchConfig()[1].config
    ngx.say(json_string)
elseif method == "POST" then
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    if not body then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say(json.encode({ error = "Missing request body" }))
        return
    end

    local data = json.decode(body)
    if not data then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say(json.encode({ error = "Invalid JSON structure" }))
        return
    end
    dbUtils.saveConfig(data)
    ngx.status = ngx.HTTP_OK
    ngx.say(json.encode({ message = "Config saved successfully" }))
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ error = "Method not allowed" }))
end