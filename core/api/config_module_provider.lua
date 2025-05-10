local json = require("cjson")
local config = require("flux_gate/core/config")

local function read_config()
    ngx.say(json.encode(config))
end

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    read_config()
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ error = "Method not allowed" }))
end