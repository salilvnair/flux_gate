local props = require("flux_gate/auth/settings/props")
local basicAuthApiSecurityConfig ={}

local function httpUnauthorized()
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say('Unauthorized')
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local function httpForbidden()
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say('Forbidden')
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

function basicAuthApiSecurityConfig.config()
    local auth_header = ngx.var.http_Authorization

    if not auth_header then
        ngx.header["WWW-Authenticate"] = 'Basic realm="Restricted"'
        return httpUnauthorized()
    end

    local m, err = ngx.re.match(auth_header, "Basic\\s+(.*)", "jo")
    if not m then
        return  httpUnauthorized()
    end
    
    local decoded = ngx.decode_base64(m[1])
    if not decoded then
        return  httpUnauthorized()
    end

    local user, pass = decoded:match("^(.*):(.*)$")
    if not user or not pass then
        return  httpUnauthorized()
    end

    if user ~= props.appBasicAuth.username or pass ~= props.appBasicAuth.password then
        return httpForbidden()
    end
end

return basicAuthApiSecurityConfig;