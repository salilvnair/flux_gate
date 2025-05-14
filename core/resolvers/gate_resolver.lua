local resolver = {}
local gatedResponse = require("flux_gate/core/model/gated_response")
local logger = require("flux_gate/core/utils/logger")

function resolver.resolve(ngx, urlConfigData)
    local gate = false
    for _, row in ipairs(urlConfigData.data) do
        if row.gate then
            gate = row.gate
            break
        end
    end
    logger.debug("Gate: " .. tostring(gate))
    if gate then
        return gatedResponse.generate(gate, urlConfigData.new_url, urlConfigData)
    else
        return gatedResponse.generate(gate, urlConfigData.old_url, urlConfigData)
    end
end
return resolver
