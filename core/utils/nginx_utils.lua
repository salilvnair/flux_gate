local nginxUtils = {}
local logger = require("flux_gate/core/utils/logger")
local json = require "cjson"
local fluxGateService = require("flux_gate/core/service/fluxgate_service")

function nginxUtils.updateUpstreams()
    local configJson = fluxGateService.loadConfig().config

    if not configJson then
        logger.debug("No Config found")
        return
    end

    local config = json.decode(configJson)

    local upstreamConfig = config.upstreamConfig

    if not upstreamConfig then
        logger.debug("No upstreamConfig found")
        return
    end

    local allUpstreamsConfig = ""

    for _, entry in ipairs(upstreamConfig) do
        local upstream_config = string.format("upstream %s {\n", entry.upstream)
        if (not entry.servers) or #entry.servers < 1 then
            logger.debug("No servers found")
            return
        end
        for _, server in ipairs(entry.servers) do
            upstream_config = upstream_config .. string.format("    server %s;\n", server.address)
        end
        upstream_config = upstream_config .. "}\n\n"
        allUpstreamsConfig = allUpstreamsConfig .. upstream_config
    end

    logger.debug("allUpstreamsConfig" .. allUpstreamsConfig)

    -- Write to a file
    local file, err = io.open("/usr/local/openresty/nginx/conf.d/fluxgate_upstreams.conf", "w")
    if not file then
        logger.debug("Failed to open file: "..err)
        return
    end

    file:write(allUpstreamsConfig)
    file:close()
end

return nginxUtils




