local json = require "cjson"
local oidcAuthService = require "flux_gate/auth/oidc/service/oidc_auth_service"

local method = ngx.req.get_method()
if method == "GET" then
    local redirectUri = oidcAuthService.generateAuthorizationUri()
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(redirectUri)
else
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    local state = post_args["state"]
    local code = post_args["code"]
    local userTokenState = oidcAuthService.authorize(state, code)
    if userTokenState then
        ngx.status = ngx.HTTP_OK
        ngx.say(json.encode(userTokenState))
    else
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say(json.encode({ error = "Unauthorized" }))
    end
end