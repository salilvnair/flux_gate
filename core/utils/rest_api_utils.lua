local restApiUtils = {}
local http = require("resty.http")

function restApiUtils.invoke(backend_url)
    local httpc = http.new()
    local res, err = httpc:request_uri(backend_url, {
        method = "GET"
    })
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