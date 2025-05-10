local restEndPointsService = {}

function restEndPointsService.register()
    local json = require("cjson")
    local gate = require("flux_gate/core/gate")
    local restApiUtils = require("flux_gate/core/utils/restapi_client_utils")
    local gateData = gate.resolve(ngx)

    if not gateData then
        ngx.status = ngx.HTTP_NOT_FOUND
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say(json.encode({ error = "No gate found" }))
        return
    end

    local logger = require "flux_gate/core/utils/logger"
    logger.debug("(nginx.conf) gateData: ".. json.encode(gateData))

    logger.debug("(nginx.conf) gate: ".. tostring(gateData.gate))
    logger.debug("(nginx.conf) old_url_upstream: ".. tostring(gateData.metadata.old_url_upstream))
    logger.debug("(nginx.conf) new_url_upstream: ".. tostring(gateData.metadata.new_url_upstream))
    local gatedUrl = gateData.gatedUrl
    if (not gateData.gate and gateData.metadata.old_url_upstream) or (gateData.gate and gateData.metadata.new_url_upstream) then
        logger.debug("(nginx.conf) going to upstream: ".. gatedUrl)
        ngx.var.target_url = gatedUrl
    else 
        logger.debug("(nginx.conf) calling url using restApiUtils: ".. gatedUrl)
        restApiUtils.invoke(gatedUrl)
    end
end

return restEndPointsService