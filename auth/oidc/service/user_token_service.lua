local userTokenService = {}
local userInfo = require("flux_gate/auth/model/user_info")
local jwt = require "resty.jwt"
local logger = require("flux_gate/core/utils/logger")
local UserRepository = require("flux_gate/auth/repo/user_repo")
local props = require("flux_gate/core/settings/props")
local Database = require("flux_gate/core/db/db")

function userTokenService.findUserInfoFromToken(idToken)
    local decoded = jwt:load_jwt(idToken)
    if not decoded.valid then
        return nil
    end
    local sub = decoded.payload.sub
    logger.debug("extracted username: " .. sub)
    return userTokenService.findUserInfo(sub)
end

function userTokenService.findUserInfo(username)
    local db = Database:new(props.db_config)
    local userRepo = UserRepository:new(db)
    local user = userRepo:findById(username)
    if not user then
        return nil
    end
    db:close()
    local roles = {
        {
            id = 1,
            name = "admin",
        },
        {
            id = 2,
            name = "user",
        },
    }
    return userInfo.generate(user.username, user.first_name, user.last_name, true, roles)
end

return userTokenService