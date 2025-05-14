local oidcAuthService = {}
local props = require("flux_gate/auth/settings/props")
local oidcAuthTokenService = require("flux_gate/auth/oidc/service/oidc_auth_token_service")
local userTokenService = require("flux_gate/auth/oidc/service/user_token_service")
local userTokenState = require("flux_gate/auth/model/user_token_state")
local logger = require("flux_gate/core/utils/logger")

function oidcAuthService.generateAuthorizationUri()
    local clientId, redirectUri, stateMetadata, codeChallenge = props.clientId, props.redirectUri, props.stateMetadata, props.codeChallenge
    local authUri = props.authUri
    local uri = authUri .. "?client_id=" .. clientId .. "&redirect_uri=" .. redirectUri
    if stateMetadata then
        uri = uri .. "&state=" .. stateMetadata
    end
    if codeChallenge then
        uri = uri .. "&code_challenge=" .. codeChallenge
    end
    return uri
end



function oidcAuthService.authorize(state, code)
    local redirectUri = oidcAuthService.generateAuthorizationUri()
    local oidcTokenResponse = oidcAuthTokenService.execute(state, code, redirectUri)
    if not oidcTokenResponse then
        logger.debug("Failed to get token response")
        return nil
    end
    if oidcTokenResponse.token_generated then
        local idToken = oidcTokenResponse.id_token
        logger.debug("ID Token: " .. idToken)
        local userInfo = userTokenService.findUserInfoFromToken(idToken)
        if not userInfo then
            logger.debug("Failed to get user info from token")
            return userTokenState.generate(false, "user not found", nil, nil, nil)
        end
        if userInfo.active then
            local userTokenStateData = {
                validToken = true,
                error = oidcTokenResponse.error,
                idToken = idToken,
                expiresIn = oidcTokenResponse.expires_in,
                userInfo = userInfo
            }
            return userTokenState.generate(userTokenStateData.validToken, userInfo.error, userInfo.idToken, userInfo.expiresIn, userInfo)
        else
            logger.debug("User is not active")
            return userTokenState.generate(false, "user not active", nil, nil, nil)
        end
    else
        logger.debug("Token generation failed: " .. oidcTokenResponse.error)
        return userTokenState.generate(false, oidcTokenResponse.error, nil, nil, nil)
    end
end


return oidcAuthService