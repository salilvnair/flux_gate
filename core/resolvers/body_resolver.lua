local resolver = {}
local ruleUtils = require("flux_gate/core/utils/rule_utils")
local gatedResponse = require("flux_gate/core/model/gated_response")

function resolver.resolve(ngx, urlConfigData)
    local request_body = ngx.req.get_body_data();
    local decision = false
    local gate = false
    for _, row in ipairs(urlConfigData.data) do
        decision = ruleUtils.evaluateRules(request_body, row.rules)
        if decision then
            gate = row.gate
            break
        end
    end
    if gate then
        return gatedResponse.generate(gate, urlConfigData.new_url, urlConfigData)
    else
        return gatedResponse.generate(gate, urlConfigData.old_url, urlConfigData)
    end
end
return resolver
