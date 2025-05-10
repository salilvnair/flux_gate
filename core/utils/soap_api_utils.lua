local http = require("resty.http")
-- local dnsUtils = require("flux_gate/core/utils/dns_utils")
local gate = require("flux_gate/core/gate")
local logger = require "flux_gate/core/utils/logger"
local soapClientUtils = {}
-- local url = require("socket.url")

function soapClientUtils.invokeSoapApi(ngx)
    
    -- local dns, err = dnsUtils.generate()
    -- if not dns then
    --     ngx.say("<html><body><h3>Error: ", err, "</h3></body></html>")
    --     return
    -- end

    -- Read the incoming SOAP request body
    ngx.req.read_body()

    local httpc = http.new()
    
    local request_body = ngx.req.get_body_data()

    -- Check if the body exists
    if not request_body then
        ngx.say("Error: No SOAP request body found.")
        ngx.exit(400)
    end

    local newUrl = gate.resolveUrl(ngx)

    local method = ngx.req.get_method()
    local body = request_body
    local headers = ngx.req.get_headers()

    -- local parsed_url = url.parse(newUrl)
    -- local host = parsed_url.host

    -- Set the content type for SOAP
    headers["Content-Type"] = "text/xml;charset=UTF-8"
    -- headers["Host"] = host

    logger.debug("newUrl:"..newUrl)
    -- logger.debug("Host:"..host)

    local res, err = httpc:request_uri(newUrl, {
        method = method,
        body = body,
        headers = headers,
        ssl_verify=false,
    })

    -- Handle response from the target URL
    if not res then
        ngx.log(ngx.DEBUG, "Failed to forward request: ", err)
        ngx.status = 500
        ngx.say("Internal Server Error")
        return
    end

    -- Send the response back to the client
    ngx.status = res.status

    logger.debug("res.status"..res.status)

    for k, v in pairs(res.headers) do
        ngx.header[k] = v
    end
    ngx.say(res.body)
end

return soapClientUtils