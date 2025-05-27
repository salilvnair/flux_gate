local oidcAuthHelper = require("flux_gate/auth/oidc/helper/oidc_auth_helper")
local logger = require("flux_gate/core/utils/logger")
local props = require("flux_gate/auth/settings/props")
local oidcSecurityConfig ={}

local function httpUnauthorized()
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header["Access-Control-Allow-Origin"] = "*"
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    ngx.header["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    ngx.say('Unauthorized')
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local function httpForbidden()
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.header["Access-Control-Allow-Origin"] = "*"
    ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    ngx.header["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    ngx.say('Forbidden')
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

function oidcSecurityConfig.config()
    local auth_config = {
        client_id = props.clientId,
        host_name =props.hostName,
        jks_site_url = props.jksSiteUrl,
    }

    -- Get Bearer token
    local auth_header = ngx.req.get_headers()["Authorization"]
    if not auth_header then
        logger.debug("Authorization header is missing")
        return httpUnauthorized()
    end

    local token = auth_header:match("Bearer%s+(.+)")
    if not token then
        logger.debug("Bearer token is missing in Authorization header")
        return httpUnauthorized()
    end



    -- Validate structure, fallback to signature verification
    if not oidcAuthHelper.validate_id_token(auth_config, token) then
        local result, err = oidcAuthHelper.verify_token_signature(auth_config, token)
        if not err then
            logger.debug("Unknown OIDC verification failed: ")
            return httpForbidden()
        end
        if not result.valid then
            logger.debug("OIDC verification failed: ".. (err.type or '')..": ".. err.description)
            return httpForbidden()
        end

    end
    ngx.ctx.id_token = token
end

return oidcSecurityConfig;






