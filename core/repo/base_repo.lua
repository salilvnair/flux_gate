
-- Base repository
local BaseRepository = {}
BaseRepository.__index = BaseRepository

function BaseRepository:new(database)
    local obj = { database = database }
    setmetatable(obj, self)
    return obj
end

return BaseRepository