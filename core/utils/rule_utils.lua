local ruleUtils = {}
local logger = require("flux_gate/core/utils/logger")
function ruleUtils.evaluateRules(data, rules)
    local finalDecision = true
    for _, rule in ipairs(rules) do
        local ruleDecision
        logger.debug("Previous rule finalDecision: " .. tostring(finalDecision))
        if rule.group then
            ruleDecision = ruleUtils.evaluateRules(data, rule.group)
        else
            ruleDecision = ruleUtils.evaluateSingleRule(data, rule)
        end
        logger.debug("Evaluating ruleDecision: " .. tostring(ruleDecision))
        if rule.operator == "AND" then
            finalDecision = finalDecision and ruleDecision
        elseif rule.operator == "OR" then
            finalDecision = finalDecision or ruleDecision
        elseif rule.operator == "NOT" then
            finalDecision = finalDecision and not ruleDecision
        else
            finalDecision = finalDecision and ruleDecision -- Default to AND if no operator is specified
        end
    end
    return finalDecision
end

function ruleUtils.evaluateSingleRule(data, rule)
    local match = false
    logger.debug("Type of data: " .. type(data))
    if type(data) == "table" then
        match = ruleUtils.evaluateTable(data, rule)
    elseif type(data) == "string" then
        match = ruleUtils.evaluateString(data, rule)
    else
        logger.debug("Unsupported data type: " .. type(data))
        return false
    end
    if rule.value == nil then
        logger.debug("Key: " .. rule.key .. " | Find: " .. tostring(match))
    else
        logger.debug("Key: " .. rule.key .. " | Value: " .. rule.value .. " | Match: " .. tostring(match))
    end
    return match
end

function ruleUtils.evaluateString(data, rule)
    local match = false
    if rule.value and data:match(rule.key) == rule.value   then
        match = true
    elseif not rule.value and data:find(rule.key) then
        match = true
    end
    return match
end

function ruleUtils.evaluateTable(obj, rule)
    local match = false
    for k, v in pairs(obj) do
        if k == rule.key and tostring(v):match(rule.value) then
            return true
        end
    end
    return match
end

return ruleUtils