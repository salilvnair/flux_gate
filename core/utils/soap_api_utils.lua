local soapClientUtils = {}
local logger = require "flux_gate/core/utils/logger"
local httpUtils = require("flux_gate/core/utils/http_utils")

function soapClientUtils.invokeSoapApi(apiUrl)
   
    local request_body = ngx.req.get_body_data()

    -- Check if the body exists
    if not request_body then
        ngx.say("Error: No SOAP request body found.")
        ngx.exit(400)
    end


    local method = ngx.req.get_method()
    local body = request_body
    local headers = ngx.req.get_headers()

    -- Set the content type for SOAP
    headers["Content-Type"] = "text/xml;charset=UTF-8"

    logger.debug("apiUrl:"..apiUrl)

    local res, err = httpUtils.exchange(apiUrl, method, headers, body, false)

    -- Handle response from the target URL
    if not res then
        logger.debug("Failed to forward request: ".. (err or "unknown error"))
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
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