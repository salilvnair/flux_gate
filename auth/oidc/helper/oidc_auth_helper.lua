local cjson = require "cjson.safe"
local jwt = require "resty.jwt"
local resty_rsa = require "resty.rsa"
local cache = ngx.shared.jwk_cache
local logger = require("flux_gate/core/utils/logger")
local httpUtils = require("flux_gate/core/utils/http_utils")

local oidcAuthHelper = {}

-- Helper: base64url decode
local function base64url_decode(input)
    input = input:gsub("-", "+"):gsub("_", "/")
    local pad = #input % 4
    if pad == 2 then input = input .. "=="
    elseif pad == 3 then input = input .. "="
    elseif pad ~= 0 then return nil end
    return ngx.decode_base64(input)
end

-- Helper: fetch and cache JWKs
local function get_cached_jwks(url, proxy_host, proxy_port)
    local jwks_cached = cache:get(url)
    if jwks_cached and type(jwks_cached) == "string" and #jwks_cached > 0 then
        logger.debug("Using cached JWKs for URL: " .. url)
    else
        logger.debug("No cached JWKs found for URL: " .. url)
    end
    if jwks_cached then return cjson.decode(jwks_cached) end

    logger.debug("Fetching JWKs from URL: " .. url)

    local res, err = httpUtils.exchange(url, httpUtils.HTTP_METHOD.GET, {}, nil, false, proxy_host, proxy_port)
    
    logger.debug("JWKs fetch response: " .. tostring(res))

    if not res or res.status ~= 200 then
        return nil, "INVALID_URL"
    end

    cache:set(url, res.body, 600) -- cache for 10 minutes
    return cjson.decode(res.body)
end

-- Helper: convert JWK to PEM
local function jwk_to_pem(jwk)
    local rsa, err = resty_rsa:new({
        key = {
            n = jwk.n,
            e = jwk.e
        },
        encoding = "base64url",
    })
    if not rsa then return nil, err end
    return rsa:to_pem(), nil
end


function oidcAuthHelper.validate_id_token(auth_config, id_token)
    local parts = {}
    for s in id_token:gmatch("([^.]+)") do table.insert(parts, s) end
    if #parts ~= 3 then return false end

    local header = base64url_decode(parts[1])
    local payload = base64url_decode(parts[2])
    if not header or not payload then return false end

    logger.debug("Decoded header: " .. header)
    logger.debug("Decoded payload: " .. payload)

    local header_json = cjson.decode(header)
    local payload_json = cjson.decode(payload)
    if not header_json or not payload_json then return false end

    local jwks, err = get_cached_jwks(auth_config.jks_site_url, auth_config.proxy_host, auth_config.proxy_port)
    logger.debug("JWKs fetched: " .. cjson.encode(jwks))
    if not jwks or not jwks.keys then return false end

    local found = false
    for _, k in ipairs(jwks.keys) do
        if k.kid == header_json.kid then
            found = true
            break
        end
    end
    if not found then return false end
    if payload_json.aud ~= auth_config.client_id then return false end
    if payload_json.iss ~= auth_config.host_name then return false end

    return true
end

function oidcAuthHelper.verify_token_signature(auth_config, id_token)
    local verifiedTokenDataBuilder = { valid = false }
    local verificationErrorBuilder = {
        type = "",
        errorId = "",
        description = "",
        category = "ID Service"
    }

    local parts = {}
    for s in id_token:gmatch("([^.]+)") do table.insert(parts, s) end
    if #parts ~= 3 then
        verificationErrorBuilder.type = "TOKEN_FAILED"
        verificationErrorBuilder.errorId = "300a.02"
        verificationErrorBuilder.description = "Malformed JWT"
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local header_raw = base64url_decode(parts[1])
    local header = cjson.decode(header_raw or "")
    if not header or not header.kid then
        verificationErrorBuilder.type = "TOKEN_FAILED"
        verificationErrorBuilder.errorId = "300a.02"
        verificationErrorBuilder.description = "Missing or invalid 'kid'"
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local jwks, err = get_cached_jwks(auth_config.jks_site_url, auth_config.proxy_host, auth_config.proxy_port)
    logger.debug("JWKs fetched: " .. cjson.encode(jwks))
    if not jwks then
        verificationErrorBuilder.type = "INVALID_URL"
        verificationErrorBuilder.errorId = "300b.01"
        verificationErrorBuilder.description = "Malformed JKS Site URL"
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local jwk
    for _, k in ipairs(jwks.keys or {}) do
        if k.kid == header.kid then
            jwk = k
            break
        end
    end
    if not jwk then
        verificationErrorBuilder.type = "KIDoidcAuthHelperISMATCH"
        verificationErrorBuilder.errorId = "300a.03"
        verificationErrorBuilder.description = "KID mismatch (not found in JWKs)"
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local pubkey, err = jwk_to_pem(jwk)
    if not pubkey then
        verificationErrorBuilder.type = "TOKEN_FAILED"
        verificationErrorBuilder.errorId = "300a.02"
        verificationErrorBuilder.description = "PEM conversion failed: " .. (err or "")
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local verified = jwt:verify(pubkey, id_token)
    if not verified.verified then
        verificationErrorBuilder.type = "TOKEN_FAILED"
        verificationErrorBuilder.errorId = "300a.02"
        verificationErrorBuilder.description = "Signature verification failed: " .. (verified.reason or "unknown")
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    local payload = verified.payload
    if payload.exp and tonumber(payload.exp) < ngx.time() then
        verificationErrorBuilder.type = "TOKEN_FAILED"
        verificationErrorBuilder.errorId = "300a.04"
        verificationErrorBuilder.description = "Token expired"
        return verifiedTokenDataBuilder, verificationErrorBuilder
    end

    verifiedTokenDataBuilder.valid = true
    return verifiedTokenDataBuilder, nil
end

return oidcAuthHelper