local json = require "cjson"
local nginxUtils = require("flux_gate/core/utils/nginx_utils")

local method = ngx.req.get_method()
if method == "GET" then
    nginxUtils.updateUpstreams()
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ message = "Upsteam saved successfully" }))
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ error = "Method not allowed" }))
end