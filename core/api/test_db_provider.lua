local json = require "cjson"
local dbUtils = require "flux_gate/core/utils/db_utils"

local function fetchUserInfo()
    local db = dbUtils.connect()
    return dbUtils.findUserInfo("salilvnair", db)
end

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.status = ngx.HTTP_OK
    local json_string = json.encode(fetchUserInfo())
    ngx.say(json_string)
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.say(json.encode({ error = "Method not allowed" }))
end
