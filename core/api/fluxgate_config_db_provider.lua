local json = require "cjson"
local dbUtils = require "flux_gate/core/utils/db_utils"

local function fetchConfig()
    local db = dbUtils.connect()
    return dbUtils.fetchConfig(db)
end

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.status = ngx.HTTP_OK
    local json_string = fetchConfig()[1].config
    ngx.say(json_string)
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.say(json.encode({ error = "Method not allowed" }))
end
