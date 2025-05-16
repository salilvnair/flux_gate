local BaseRepository = require("flux_gate/core/repo/base_repo")
local FluxGateConfig = require("flux_gate/core/entity/config_entity")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")

local FluxGateConfigRepository = {}
FluxGateConfigRepository.__index = FluxGateConfigRepository
setmetatable(FluxGateConfigRepository, BaseRepository)

function FluxGateConfigRepository:new(database)
    local obj = BaseRepository:new(database)
    setmetatable(obj, self)
    return obj
end

function FluxGateConfigRepository:save(data)
    local metadata = FluxGateConfig.__metadata
    assert(metadata and metadata.table and metadata.columns, "Entity metadata is not properly defined!")

    local modified_timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entity = {
        id = 1,
        config = json.encode(data.config),
        modified = modified_timestamp,
        userId = data.userName,
        notes = "Saving from console"
    }

    logger.debug("Preparing to save entity: " .. json.encode(entity))

    local tableName = metadata.table
    local columnNames, values = {}, {}
    local idColumn, idValue

    local existingEntity = self:findById(entity.id)
    logger.debug("Existing entity: " .. (existingEntity and json.encode(existingEntity) or "nil"))

    for key, columnInfo in pairs(metadata.columns) do
        local columnName = columnInfo.column
        table.insert(columnNames, columnName)

        local value = entity[key]
        if columnInfo.id then
            idColumn = columnName
            idValue = value
            if not existingEntity then
                table.insert(values, value)
            end
        else
            table.insert(values, value)
        end
    end

    assert(idColumn and idValue, "Entity must have a defined ID field in metadata!")

    if existingEntity then
        -- UPDATE
        local updateSet = {}
        for _, column in ipairs(columnNames) do
            if column ~= idColumn then
                table.insert(updateSet, string.format("%s = ?", column))
            end
        end
        local query = string.format(
            "UPDATE %s SET %s WHERE %s = ?",
            tableName,
            table.concat(updateSet, ", "),
            idColumn
        )
        table.insert(values, idValue)
        logger.debug("Update Query: " .. query)
        self.database:execute(query, values)
        logger.debug("Entity updated successfully.")
    else
        -- INSERT
        local placeholders = table.concat({ string.rep("?", #columnNames) }, ", "):gsub(", $", "")
        local query = string.format(
            "INSERT INTO %s (%s) VALUES (%s)",
            tableName,
            table.concat(columnNames, ", "),
            placeholders
        )
        logger.debug("Insert Query: " .. query)
        self.database:execute(query, values)
        logger.debug("Entity inserted successfully.")
    end
end

function FluxGateConfigRepository:findById(id)
    local metadata = FluxGateConfig.__metadata
    assert(metadata and metadata.table and metadata.id, "Entity metadata is not properly defined!")
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.id)
    local results = self.database:execute(query, { id })
    return results and results[1]
end

function FluxGateConfigRepository:deleteById(id)
    local metadata = FluxGateConfig.__metadata
    assert(metadata and metadata.table and metadata.id, "Entity metadata is not properly defined!")
    local query = string.format("DELETE FROM %s WHERE %s = ?", metadata.table, metadata.id)
    self.database:execute(query, { id })
    logger.debug("Entity deleted successfully.")
end

return FluxGateConfigRepository
