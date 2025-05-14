
local BaseRepository = require("flux_gate/core/repo/base_repo")
local UserRole = require("flux_gate/auth/entity/user_role")
local Role = require("flux_gate/auth/entity/role")
local logger = require("flux_gate/core/utils/logger")
local json = require("cjson")

local UserRoleRepository = {}
UserRoleRepository.__index = UserRoleRepository
setmetatable(UserRoleRepository, BaseRepository)

function UserRoleRepository:new(database)
    local obj = BaseRepository:new(database)
    setmetatable(obj, self)
    return obj
end

function UserRoleRepository:findById(id)
    local metadata = UserRole.__metadata
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.id)
    local results = self.database:execute(query, { id })
    return results[1]
end

function UserRoleRepository:findByUserId(userId)
    local userRoleMetadata = UserRole.__metadata
    local roleMetadata = Role.__metadata
    local query = string.format("SELECT t1.*, t2.role_name FROM %s t1, %s t2 WHERE t1.role_id = t2.role_id and t1.%s = ?", userRoleMetadata.table, roleMetadata.table, userRoleMetadata.columns.userId.column)
    local results = self.database:execute(query, { userId })
    return results
end

return UserRoleRepository