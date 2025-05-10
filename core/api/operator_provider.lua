local json = require "cjson"

local function operators()
    local availableResolvers = {
        "AND",
        "OR",
        "NOT",
    }
    return availableResolvers
end

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.status = ngx.HTTP_OK
    local json_string = json.encode(operators())
    ngx.say(json_string)
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.say(json.encode({ error = "Method not allowed" }))
end
