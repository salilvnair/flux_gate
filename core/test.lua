local FluxGateConfig = require("entity/config_entity")
local metadata = FluxGateConfig.__metadata
local config = require("config")

local entity = {
    id = 1,
    config = "config json here",
    modified = os.date("%Y-%m-%d %H:%M:%S"),
    userId = "salilvnair",
    notes = "Saving from console",
}
    
if not metadata or not metadata.table or not metadata.columns then
    error("Entity metadata is not properly defined!")
end

local tableName = metadata.table
local idColumn = nil
local idValue = nil
local columnNames, values = {}, {}

for key, columnInfo in pairs(metadata.columns) do
    table.insert(columnNames, columnInfo.column)
    if columnInfo.id then
        idColumn = columnInfo.column
        idValue = entity[key]
    else
        table.insert(values, entity[key])
    end
end


local existingEntity = false
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
    print("Update Query:"..query)
    print("values:"..table.concat(values, ", "))
    print("Entity updated successfully!")
else
    -- Build INSERT query
    local placeholders = string.rep("?", #columnNames, ", "):gsub(", $", "")
    local query = string.format(
        "INSERT INTO %s (%s) VALUES (%s)",
        tableName,
        table.concat(columnNames, ", "),
        placeholders
    )
    print("Insert Query:"..query)
    print("Values: "..table.concat(values, ", "))
    print("Entity inserted successfully!")
end