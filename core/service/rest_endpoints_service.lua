local restEndPointsService = {}
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")
local restApiUtils = require("flux_gate/core/utils/rest_api_utils")
local gate = require("flux_gate/core/gate")

function restEndPointsService.register()
    -- Read the incoming Rest request body
    ngx.req.read_body()
    local gateData = gate.resolve(ngx)

    if not gateData then
        ngx.status = ngx.HTTP_NOT_FOUND
        ngx.header.content_type = "application/json; charset=utf-8"
        ngx.say(json.encode({ error = "No gate found" }))
        return
    end

    logger.debug("(restEndPointsService) gateData: ".. json.encode(gateData))
    logger.debug("(restEndPointsService) gate: ".. tostring(gateData.gate))
    logger.debug("(restEndPointsService) old_url_upstream: ".. tostring(gateData.metadata.old_url_upstream))
    logger.debug("(restEndPointsService) new_url_upstream: ".. tostring(gateData.metadata.new_url_upstream))
    local gatedUrl = gateData.gatedUrl
    if (not gateData.gate and (gateData.metadata.old_url_upstream or gateData.metadata.upstream)) or (gateData.gate and gateData.metadata.new_url_upstream) then
        logger.debug("(restEndPointsService) going to upstream: ".. gatedUrl)
        ngx.var.target_url = gatedUrl
    else
        logger.debug("(restEndPointsService) calling url using restApiUtils: ".. gatedUrl)
        restApiUtils.invoke(gatedUrl)
    end
end

return restEndPointsService