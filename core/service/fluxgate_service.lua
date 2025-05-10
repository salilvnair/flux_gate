local fluxGateService = {}
local props = require("flux_gate/core/settings/props")
local Database = require("flux_gate/core/db/db")
local FluxGateConfigRepository = require("flux_gate/core/repo/config_repo")

function fluxGateService.saveConfig(config)
    local db = Database:new(props.db_config)
    local configRepo = FluxGateConfigRepository:new(db)
    configRepo:save(config)
    db:close()
    -- dbUtils.saveConfig(config)
end

function fluxGateService.loadConfig()
    local db = Database:new(props.db_config)
    local configRepo = FluxGateConfigRepository:new(db)
    local configData = configRepo:findById(1)
    db:close()
    return configData
end


return fluxGateService

