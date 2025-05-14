local userTokenService = {}
local userInfo = require("flux_gate/auth/model/user_info")
local jwt = require "resty.jwt"
local logger = require("flux_gate/core/utils/logger")
local UserRepository = require("flux_gate/auth/repo/user_repo")
local UserRoleRepository = require("flux_gate/auth/repo/user_role_repo")
local props = require("flux_gate/core/settings/props")
local Database = require("flux_gate/core/db/db")
local json = require("cjson")

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
    local roles = userTokenService.findUserRoleInfo(username)
    logger.debug("user: " .. json.encode(user))
    local userActive = false
    if user.active == 'Y' then
        userActive = true
    end
    return userInfo.generate(user.user_id, user.first_name, user.last_name, userActive, roles)
end

function userTokenService.findUserRoleInfo(username)
    local db = Database:new(props.db_config)
    local userRoleRepo = UserRoleRepository:new(db)
    local dbUserRoles = userRoleRepo:findByUserId(username)
    if not dbUserRoles then
        return nil
    end
    db:close()
    logger.debug("user roles: " .. json.encode(dbUserRoles))
    local userRoles = {}
    for _, userRole in ipairs(dbUserRoles) do
        table.insert(userRoles, userInfo.generateRole(userRole.role_id, userRole.role_name))
    end
    return userRoles
end

return userTokenService