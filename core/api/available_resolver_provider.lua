local fileUtils = require("flux_gate/core/utils/file_utils")
local props = require("flux_gate/core/settings/props")
local json = require "cjson"

local function availableResolvers()
    local resolvers = fileUtils.find_lua_files_without_extension(props.resolver_path)
    local availableResolvers = {}
    if not resolvers then
        return availableResolvers
    end
    for _, resolver in ipairs(resolvers) do
        if resolver then
            table.insert(availableResolvers, "resolvers/" .. resolver)
        end
    end
    return availableResolvers
end 

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.status = ngx.HTTP_OK
    local json_string = json.encode(availableResolvers())
    json_string = string.gsub(json_string, "\\/", "/")
    ngx.say(json_string)
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.say(json.encode({ error = "Method not allowed" }))
end
