local memoryUtils = {}
local logger = require("flux_gate/core/utils/logger")
local props = require("flux_gate/core/settings/props")

function memoryUtils.log_memory(premature)
    if premature then return end
    -- Get Lua memory in KB
    local mem_kb = collectgarbage("count")
    -- Log to error log
    logger.info("[MEM] Lua memory usage: " .. mem_kb .. " KB")

    -- Schedule next run in 60 seconds
    local ok, err = ngx.timer.at(props.memory_log_interval, memoryUtils.log_memory)
    if not ok then
        logger.error("Failed to schedule memory logger: ".. (err or 'unknown'))
    end
end


function memoryUtils.log()
    -- Start the first run
    local ok, err = ngx.timer.at(0, memoryUtils.log_memory)
    if not ok then
        logger.error("Failed to start memory logger: ".. (err or 'unknown'))
    end
end

return memoryUtils