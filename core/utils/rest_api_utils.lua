local restApiUtils = {}
local httpUtils = require("flux_gate/core/utils/http_utils")

function restApiUtils.invoke(apiUrl)
    local method = ngx.req.get_method()
    local headers = ngx.req.get_headers()
    ngx.req.read_body()
    local request_body = ngx.req.get_body_data()

    local res, err = httpUtils.exchange(apiUrl, method, headers, request_body, false)
    if not res then
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.say("Error calling backend: ", err)
        return
    end
    local received_headers = res.headers
    for key, value in pairs(received_headers) do
        ngx.header[key] = value
    end
    ngx.header["Server"] = nil
    ngx.header["Keep-Alive"] = nil
    ngx.status = res.status
    ngx.say(res.body)
end

return restApiUtils;