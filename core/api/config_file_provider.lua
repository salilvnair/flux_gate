local json = require "cjson"
local configUtils = require("flux_gate/core/utils/config_utils")
local props = require("flux_gate/core/settings/props")
local fluxGateService = require("flux_gate/core/service/fluxgate_service")

local function save_config()
    local json_string = fluxGateService.loadConfig().config

    local data = json.decode(json_string)
    if not data then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say(json.encode({ error = "Invalid JSON structure" }))
        return
    end

    configUtils.write_lua_file(props.config_path, data)

    ngx.status = ngx.HTTP_OK
    ngx.say(json.encode({ message = "Config saved successfully" }))
end


local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    save_config()
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ error = "Method not allowed" }))
end
