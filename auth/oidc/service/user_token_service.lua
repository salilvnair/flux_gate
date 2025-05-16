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
    if not decoded or not decoded.valid then
        logger.error("Invalid JWT token")
        return nil
    end
    local sub = decoded.payload.sub
    logger.debug("Extracted username from token: " .. tostring(sub))
    return userTokenService.findUserInfo(sub)
end

function userTokenService.findUserInfo(username)
    local db, err = Database:new(props.db_config)
    if not db then
        logger.error("DB initialization failed in findUserInfo: " .. (err or "unknown"))
        return nil
    end

    local userRepo = UserRepository:new(db)
    local user
    local ok, execErr = pcall(function()
        user = userRepo:findById(username)
    end)
    db:close()

    if not ok then
        logger.error("findUserInfo failed: " .. tostring(execErr))
        return nil
    end

    if not user then
        logger.debug("User not found for username: " .. username)
        return nil
    end

    local roles = userTokenService.findUserRoleInfo(username)

    logger.debug("User fetched: " .. json.encode(user))

    local userActive = user.active == 'Y'
    return userInfo.generate(user.user_id, user.first_name, user.last_name, userActive, roles)
end

function userTokenService.findUserRoleInfo(username)
    local db, err = Database:new(props.db_config)
    if not db then
        logger.error("DB initialization failed in findUserRoleInfo: " .. (err or "unknown"))
        return nil
    end

    local userRoleRepo = UserRoleRepository:new(db)
    local dbUserRoles
    local ok, execErr = pcall(function()
        dbUserRoles = userRoleRepo:findByUserId(username)
    end)
    db:close()

    if not ok then
        logger.error("findUserRoleInfo failed: " .. tostring(execErr))
        return nil
    end

    if not dbUserRoles then
        logger.debug("No roles found for user: " .. username)
        return nil
    end

    logger.debug("User roles: " .. json.encode(dbUserRoles))

    local userRoles = {}
    for _, userRole in ipairs(dbUserRoles) do
        table.insert(userRoles, userInfo.generateRole(userRole.role_id, userRole.role_name))
    end

    return userRoles
end

return userTokenService
