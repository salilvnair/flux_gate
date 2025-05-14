
local BaseRepository = require("flux_gate/core/repo/base_repo")
local User = require("flux_gate/auth/entity/user")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")

local UserRepository = {}
UserRepository.__index = UserRepository
setmetatable(UserRepository, BaseRepository)

function UserRepository:new(database)
    local obj = BaseRepository:new(database)
    setmetatable(obj, self)
    return obj
end

function UserRepository:save(newConfig)

    local modified_timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entity = {
        config = json.encode(newConfig),
        modified = modified_timestamp,
        userId = "salilvnair",
        notes = "Saving from console",
    }

    logger.debug("entity"..json.encode(entity))

    local metadata = User.__metadata
    
    if not metadata or not metadata.table or not metadata.columns then
        error("Entity metadata is not properly defined!")
    end

    local tableName = metadata.table
    local idColumn = nil
    local idValue = nil
    local columnNames, values= {}, {}

    -- Check if the entity exists
    local existingEntity = self:findById(1)

    logger.debug("existingEntity"..json.encode(existingEntity))

    for key, columnInfo in pairs(metadata.columns) do
        table.insert(columnNames, columnInfo.column)
        if columnInfo.id then
            idColumn = columnInfo.column
            idValue = entity[key]
            if not existingEntity then
                table.insert(values, entity[key])
            end
        else
            table.insert(values, entity[key])
        end
    end

    if not idColumn or not idValue then
        error("Entity must have a defined ID field in metadata!")
    end


    if existingEntity then
        -- Build UPDATE query
        local updateColumns = {}
        for i, column in ipairs(columnNames) do
            if column ~= idColumn then
                table.insert(updateColumns, string.format("%s = ?", column))
            end
        end


        local query = string.format(
            "UPDATE %s SET %s WHERE %s = ?",
            tableName,
            table.concat(updateColumns, ", "),
            idColumn
        )

        table.insert(values, idValue) -- Add ID as the last parameter

        logger.debug("Update Query:"..query)
        logger.debug("Values: ", json.encode(values))

        self.database:execute(query, values)
        logger.debug("Entity updated successfully!")
    else
        -- Build INSERT query
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
end

function UserRepository:findById(id)
    local metadata = User.__metadata
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.id)
    local results = self.database:execute(query, { id })
    return results[1]
end


function UserRepository:deleteById(id)
    local metadata = User.__metadata
    local query = string.format("DELETE FROM %s WHERE %s = ?", metadata.table, metadata.id)
    self.database:execute(query, { id })
    logger.debug("Entity deleted successfully!")
end


return UserRepository