local http = require("resty.http")
local logger = require("flux_gate/core/utils/logger")
local dnsUtils = require("flux_gate/core/utils/dns_utils")
local url_parser = require("socket.url")

local HTTP_METHOD = {
    GET = "GET",
    POST = "POST",
    PUT = "PUT",
    DELETE = "DELETE",
}

local function exchange(url, method, headers, body, ssl_verify, proxy_host, proxy_port)

    local httpc = http.new()

    if proxy_host and proxy_port then
        httpc:set_proxy_options({
            http_proxy = "http://" .. proxy_host .. ":" .. proxy_port
        })
    end

    if not url then
        logger.error("URL is nil")
        return
    end

    if not method then
        logger.error("HTTP method is nil")
        return
    end

    logger.debug("Input URL: " .. url)
    
    local res, err = nil, nil

    local parsed = url_parser.parse(url)

    local scheme = parsed.scheme
    local host = parsed.host
    local path = parsed.path or "/"

    local ip, iperr = dnsUtils.resolveHost(host)

    if not ip then
        logger.error("Failed to resolve host: " .. host .. ", error: " .. (iperr or "unknown error"))
        return
    end

    local resolvedUrl = scheme .. "://" .. ip .. ":" .. (parsed.port or (scheme == "https" and 443 or 80)) .. path

    logger.debug("Resolved URL: " .. resolvedUrl .. " | Host: "..host)

    headers["Host"] = host
    headers["host"] = host

    logger.debug("request headers for :"..resolvedUrl)

    for k, v in pairs(headers) do
        ngx.header[k] = v
        logger.debug("k: "..k)
        logger.debug("v: "..v)
    end

    if HTTP_METHOD.GET == method then
        res, err = httpc:request_uri(resolvedUrl, {
            method = method,
            headers = headers,
            ssl_verify = ssl_verify or false,
        })
    else
        res, err = httpc:request_uri(resolvedUrl, {
            method = method,
            body = body,
            headers = headers,
            ssl_verify = ssl_verify or false,
        })
    end

    return res, err
end

return {
    HTTP_METHOD = HTTP_METHOD,
    exchange = exchange
}