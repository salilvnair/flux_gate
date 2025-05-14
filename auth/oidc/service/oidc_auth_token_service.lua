local oidcAuthTokenService = {}
local props = require("flux_gate/auth/settings/props")
local http = require("resty.http")
local oidcTokenResponse = require("flux_gate/auth/oidc/model/oidc_token_response")
local cjson = require("cjson")
local logger = require("flux_gate/core/utils/logger")



function oidcAuthTokenService.execute(state, code, redirectUri)
    local clientId, codeVerifier, clientSecret = props.clientId, props.codeVerifier, props.clientSecret
    local grantType = props.grantType
    local formBody = {
        client_id = clientId,
        code = code,
        code_verifier = codeVerifier,
        client_secret = clientSecret,
        grant_type = grantType,
        redirect_uri = redirectUri
    }
    local httpc = http.new()

    local res, err = httpc:request_uri(props.tokenUri, {
        method = "POST",
        body = ngx.encode_args(formBody),
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })

    if not res then
        ngx.log(ngx.ERR, "failed to request: ", err)
        return nil
    end

    if res.status ~= 200 then
        ngx.log(ngx.ERR, "failed to get token: ", res.body)
        return nil
    end

    local tokenResponse = cjson.decode(res.body)

    logger.debug("Token response: ".. res.body)



    local odicTokenResponseData =  oidcTokenResponse.generate(
        tokenResponse.id_token,
        tokenResponse.access_token,
        tokenResponse.refresh_token,
        tokenResponse.token_type,
        tokenResponse.expires_in,
        tokenResponse.error,
        tokenResponse. error_description,
        true
    )
    if not tokenResponse.id_token then
        odicTokenResponseData.token_generated = false
        odicTokenResponseData.error = tokenResponse.error
        odicTokenResponseData.error_description = tokenResponse.error_description
    end

    logger.debug("id_token cond:"..tostring(tokenResponse.id_token))

    return odicTokenResponseData

end

return oidcAuthTokenService