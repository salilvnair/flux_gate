local json = require "cjson"
local oidcAuthService = require "flux_gate/auth/oidc/service/oidc_auth_service"

local function generateAuthorizationUri()
    local redirectUri = oidcAuthService.generateAuthorizationUri()
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(redirectUri)
end


local function authorize()
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

local method = ngx.req.get_method()
if method == "GET" then
    local uri = ngx.var.uri
    if uri == "/auth/redirect" then
        generateAuthorizationUri()
    elseif uri == "/auth/authorize" then
        authorize()
    else
        ngx.status = 404
        ngx.say("Unknown endpoint")
    end
else
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.header.content_type = "application/json; charset=utf-8"
    local response = {
        error = "Invalid request method",
        message = "Only GET method is allowed"
    }
    ngx.say(json.encode(response))
end


