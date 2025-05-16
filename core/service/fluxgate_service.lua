local fluxGateService = {}
local props = require("flux_gate/core/settings/props")
local Database = require("flux_gate/core/db/db")
local FluxGateConfigRepository = require("flux_gate/core/repo/config_repo")
local logger = require("flux_gate/core/utils/logger")

function fluxGateService.saveConfig(data)
    local db, err = Database:new(props.db_config)
    if not db then
        logger.error("DB initialization failed in saveConfig: " .. (err or "unknown"))
        return false, "Database error"
    end

    local configRepo = FluxGateConfigRepository:new(db)
    local ok, execErr = pcall(function()
        configRepo:save(data)
    end)

    db:close()

    if not ok then
        logger.error("saveConfig failed: " .. tostring(execErr))
        return false, execErr
    end

    return true
end

function fluxGateService.loadConfig()
    local db, err = Database:new(props.db_config)
    if not db then
        logger.error("DB initialization failed in loadConfig: " .. (err or "unknown"))
        return nil, "Database error"
    end

    local configRepo = FluxGateConfigRepository:new(db)
    local configData
    local ok, execErr = pcall(function()
        configData = configRepo:findById(1)
    end)

    db:close()

    if not ok then
        logger.error("loadConfig failed: " .. tostring(execErr))
        return nil, execErr
    end

    return configData
end

return fluxGateService
