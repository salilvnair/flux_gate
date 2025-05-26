local json = require "cjson"
local nginxUtils = require("flux_gate/core/utils/nginx_utils")

local function updateUpstreams()
    nginxUtils.updateUpstreams()
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ message = "Upsteam saved successfully" }))
end

local function updateNameResolver()
    nginxUtils.updateNameResolver()
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ message = "Name resolvers saved successfully" }))
end

local method = ngx.req.get_method()
if method == "GET" then
    local uri = ngx.var.uri
    if uri == "/nginx/updateUpstream" then
        updateUpstreams()
    elseif uri == "/nginx/updateNameResolver" then
        updateNameResolver()
    else
        ngx.status = 404
        ngx.say("Unknown endpoint")
    end
else
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = "application/json; charset=utf-8"
    local response = {
        error = "Invalid request method",
        message = "Only GET method is allowed"
    }
    ngx.say(json.encode(response))
end
