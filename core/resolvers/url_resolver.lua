local resolver = {}
local ruleUtils = require("flux_gate/core/utils/rule_utils")
local gatedResponse = require("flux_gate/core/model/gated_response")
local json = require("cjson.safe")

function resolver.resolve(ngx, urlConfigData)
    local uri = ngx.var.request_uri
    local decision = false
    local gate = false
    for _, row in ipairs(urlConfigData.data) do
        decision = ruleUtils.evaluateRules(uri, row.rules)
        if decision then
            gate = row.gate
            break
        end
    end
    ngx.log(ngx.DEBUG, "Decision: " .. tostring(decision))
    ngx.log(ngx.DEBUG, "Gate: " .. tostring(gate))
    ngx.log(ngx.DEBUG, "urlConfigData: " .. json.encode(urlConfigData))

    if gate then
        return gatedResponse.generate(gate, urlConfigData.new_url, urlConfigData)
    else
        return gatedResponse.generate(gate, urlConfigData.old_url, urlConfigData)
    end
end
return resolver
