local soapClientUtils = {}
local gate = require("flux_gate/core/gate")
local logger = require "flux_gate/core/utils/logger"
local httpUtils = require("flux_gate/core/utils/http_utils")

function soapClientUtils.invokeSoapApi(ngx)

    -- Read the incoming SOAP request body
    ngx.req.read_body()

   
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

    -- Set the content type for SOAP
    headers["Content-Type"] = "text/xml;charset=UTF-8"

    logger.debug("newUrl:"..newUrl)

    local res, err = httpUtils.exchange(newUrl, method, headers, body, false)

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