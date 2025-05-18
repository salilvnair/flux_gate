
local BaseRepository = require("flux_gate/core/repo/base_repo")
local FluxGateConfigLog = require("flux_gate/core/entity/config_log_entity")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")

local FluxGateConfigLogRepository = {}
FluxGateConfigLogRepository.__index = FluxGateConfigLogRepository
setmetatable(FluxGateConfigLogRepository, BaseRepository)

function FluxGateConfigLogRepository:new(database)
    local obj = BaseRepository:new(database)
    setmetatable(obj, self)
    return obj
end

function FluxGateConfigLogRepository:save(data)
    local modified_timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entity = {
        config = json.encode(data.config),
        modified = modified_timestamp,
        userId = data.userName,
        notes = data.notes,
    }

    logger.debug("entity"..json.encode(entity))

    local metadata = FluxGateConfigLog.__metadata
    
    if not metadata or not metadata.table or not metadata.columns then
        error("Entity metadata is not properly defined!")
    end

    local tableName = metadata.table
    local columnNames, values= {}, {}

    for key, columnInfo in pairs(metadata.columns) do
        if not columnInfo.id then
            table.insert(columnNames, columnInfo.column)
            table.insert(values, entity[key])
        end
    end

    local placeholders = string.rep("?", #columnNames, ", "):gsub(", $", "")
    local query = string.format(
        "INSERT INTO %s (%s) VALUES (%s)",
        tableName,
        table.concat(columnNames, ", "),
        placeholders
    )
    logger.debug("Insert Query:"..query)
    logger.debug("Values: ", json.encode(values))
    self.database:execute(query, values)
    logger.debug("Entity inserted successfully!")
end


return FluxGateConfigLogRepository