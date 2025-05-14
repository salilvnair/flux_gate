
local BaseRepository = require("flux_gate/core/repo/base_repo")
local Role = require("flux_gate/auth/entity/role")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")

local RoleRepository = {}
RoleRepository.__index = RoleRepository
setmetatable(RoleRepository, BaseRepository)

function RoleRepository:new(database)
    local obj = BaseRepository:new(database)
    setmetatable(obj, self)
    return obj
end

function RoleRepository:findById(id)
    local metadata = Role.__metadata
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.id)
    local results = self.database:execute(query, { id })
    return results[1]
end

function RoleRepository:findByUserId(userId)
    local metadata = Role.__metadata
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.columns.userId.column)
    local results = self.database:execute(query, { userId })
    return results
end

return RoleRepository