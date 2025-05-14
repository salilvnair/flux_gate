
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

function UserRepository:findById(id)
    local metadata = User.__metadata
    local query = string.format("SELECT * FROM %s WHERE %s = ?", metadata.table, metadata.id)
    local results = self.database:execute(query, { id })
    return results[1]
end

return UserRepository