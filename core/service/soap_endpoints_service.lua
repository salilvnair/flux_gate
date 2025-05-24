local soapEndpointsService = {}
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")
local soapApiUtils = require("flux_gate/core/utils/soap_api_utils")
local gate = require("flux_gate/core/gate")

function soapEndpointsService.register()
    -- Read the incoming SOAP request body
    ngx.req.read_body()
    local gateData = gate.resolve(ngx)

    if not gateData then
        ngx.log(ngx.DEBUG, "Failed to forward request: ", err)
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.header.content_type = "text/xml;charset=UTF-8"
        ngx.say("Internal Server Error")
        return
    end

    logger.debug("(soapEndpointsService) gateData: ".. json.encode(gateData))
    logger.debug("(soapEndpointsService) gate: ".. tostring(gateData.gate))
    logger.debug("(soapEndpointsService) old_url_upstream: ".. tostring(gateData.metadata.old_url_upstream))
    logger.debug("(soapEndpointsService) new_url_upstream: ".. tostring(gateData.metadata.new_url_upstream))

    local gatedUrl = gateData.gatedUrl
    if (not gateData.gate and (gateData.metadata.old_url_upstream or gateData.metadata.upstream)) or (gateData.gate and gateData.metadata.new_url_upstream) then
        logger.debug("(soapEndpointsService) going to upstream: ".. gatedUrl)
        ngx.var.target_url = gatedUrl
    else
        logger.debug("(soapEndpointsService) calling url using soapApiUtils: ".. gatedUrl)
        soapApiUtils.invokeSoapApi(gatedUrl)
    end
    
end

return soapEndpointsService