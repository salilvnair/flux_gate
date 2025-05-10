local tableUtils = require("flux_gate/core/utils/table_utils")
local config = require("flux_gate/core/config")
local gatedResponse = require("flux_gate/core/model/gated_response")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson.safe")

local function interceptedResponse(id, apiConfigData)
    return {
        id = id,
        apiConfigData = apiConfigData,
    }
end

local function intercept(ngx)
    logger.debug("Intercepting request...")
    local subcontext = ngx.var.request_uri
    logger.debug("Intercepted subcontext: " .. subcontext)
    tableUtils.sort(config.urlConfig, 'subcontext')
    local data = config.urlConfig
    if not data then
        return nil
    end
    local uri = ngx.var.request_uri
    for _, entry in ipairs(data) do
        if string.find(uri, entry.subcontext, 1, true) then
            logger.debug("Provided subcontext: " .. uri)
            logger.debug("Intercepted subcontext: " .. entry.subcontext .. " | id: " .. entry.id)
            local apiConfig = config.apiConfig
            if not data then
                return interceptedResponse(entry.id, nil)
            end
            local apiConfigData = apiConfig[entry.id]
            if not apiConfigData then
                return interceptedResponse(entry.id, nil)
            end
            return interceptedResponse(entry.id, apiConfigData)
        end
    end
    return nil
end

local function gate(ngx)
    local interceptedData = intercept(ngx)
    if not interceptedData or not interceptedData.apiConfigData then
        local resolvedUrl = config.defaultConfig.old_url
        if not resolvedUrl then
            return nil
        end
        return gatedResponse.generate(false, resolvedUrl, nil)
    end

    local resolver_module = interceptedData.apiConfigData.resolver_module
    if not resolver_module then
        return gatedResponse.generate(false, interceptedData.apiConfigData.old_url, interceptedData.apiConfigData)
    end

    if not interceptedData.apiConfigData.active then
        return gatedResponse.generate(false, interceptedData.apiConfigData.old_url, interceptedData.apiConfigData)
    end

    local resolver = require("flux_gate/core/" .. resolver_module)
    return resolver.resolve(ngx, interceptedData.apiConfigData)
end


local function resolve(ngx)
    logger.debug("Resolving URL...")
    local gateData = gate(ngx)
    logger.debug("Gated response: " .. json.encode(gateData))
    if not gateData then
        return nil
    end
    local port = ngx.var.server_port
    local subcontext = ngx.var.request_uri
    local gatedUrl = gateData.gatedUrl;
    logger.debug("gatedUrl: " .. gatedUrl)
    if not gatedUrl then
        return nil
    end
    if gateData.gate then
        return gatedResponse.generate(true,  gateData.gatedUrl, gateData.metadata)
    end
    local resolvedUrl = string.gsub(gatedUrl, "{{SERVER_PORT}}", port)
    if not gateData.metadata.old_url_upstream then
        resolvedUrl =  resolvedUrl .. subcontext
    end
    logger.debug("resolvedUrl: " .. resolvedUrl)
    return gatedResponse.generate(false,  resolvedUrl, gateData.metadata)
end

local function resolveUrl(ngx)
    logger.debug("Resolving URL...")
    local gateData = gate(ngx)
    logger.debug("Gated response: " .. json.encode(gateData))
    if not gateData then
        return nil
    end
    local port = ngx.var.server_port
    local subcontext = ngx.var.request_uri
    local gatedUrl = gateData.gatedUrl;
    logger.debug("gatedUrl: " .. gatedUrl)
    if not gatedUrl then
        return nil
    end
    if gateData.gate then
        return gateData.gatedUrl
    end
    local resolvedUrl = string.gsub(gatedUrl, "{{SERVER_PORT}}", port)
    logger.debug("resolvedUrl: " .. resolvedUrl)
    resolvedUrl = resolvedUrl .. subcontext
    return resolvedUrl
end

return {
    intercept = intercept,
    resolveUrl = resolveUrl,
    resolve = resolve
}
