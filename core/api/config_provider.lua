local json = require("cjson")
local fluxGateService = require("flux_gate/core/service/fluxgate_service")

local function read_config()
    local flexGateConfig = fluxGateService.loadConfig()
    if not flexGateConfig then
        ngx.say(json.encode({}))
    end
    ngx.say(flexGateConfig.config)
end

local function save_config()
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

    fluxGateService.saveConfig(data)

    ngx.status = ngx.HTTP_OK
    ngx.say(json.encode({ message = "Config saved successfully" }))
end

local method = ngx.req.get_method()
if method == "GET" then
    ngx.header.content_type = "application/json; charset=utf-8"
    read_config()
elseif method == "POST" then
    ngx.header.content_type = "application/json; charset=utf-8"
    save_config()
else
    ngx.status = ngx.HTTP_NOT_ALLOWED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode({ error = "Method not allowed" }))
end