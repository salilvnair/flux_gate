local consoleUtils = {}
local logger = require("flux_gate/core/utils/logger")

function consoleUtils.initEnvConfigAndLoadHtml(base_url)
    local fluxgate_shared_dict = ngx.shared.fluxgate_shared_dict

    local index_config_initialized = fluxgate_shared_dict:get("index_config_initialized")

    if not index_config_initialized then
        local file_path = "/usr/local/openresty/lualib/flux_gate/console/index.html"
        -- local base_url = "http://localhost:9090"

        -- Read the index.html file
        local file = io.open(file_path, "r")
        if not file then
            ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
            ngx.say("Could not read index.html")
            return
        end

        local content = file:read("*all")

        logger.debug("index.html content: " .. content)

        file:close()

        -- Replace the placeholder with the base URL
        content = string.gsub(content, "{{API_BASE_URL}}", base_url)

        local file = io.open(file_path, "w")
        if not file then
            ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
            ngx.say("Could not read index.html")
            return
        end
        if content then
            file:write(content)
            file:close() 
            -- Cache the replaced content for subsequent requests
            fluxgate_shared_dict:set("index_config_initialized", true)
            fluxgate_shared_dict:set("cached_index", content)
        end
    end
end


function consoleUtils.initIndexHtml(base_url)
    -- Generate a random 16-byte nonce and encode it in base64
	local nonce = ngx.encode_base64(random.bytes(16))
	ngx.ctx.nonce = nonce -- Store the nonce in the request context

	-- Load the Angular index.html
	local html = ngx.location.capture("/index.html").body
    -- -- replace API Base URL
	html = html:gsub("{{API_BASE_URL}}", base_url)

	-- Replace the {{nonce}} placeholder with the generated nonce
	html = html:gsub("{{nonce}}", ngx.ctx.nonce)

	-- Set the Content-Security-Policy header
	ngx.header["Content-Security-Policy"] =
		"default-src 'self'; " ..
		"script-src 'self' 'nonce-" .. nonce .. "'; " ..
		"style-src 'self' 'unsafe-inline'; " ..
		"connect-src 'self';" ..
		"img-src 'self' data:; font-src 'self'; object-src 'none';"

	-- Serve the modified HTML
	ngx.header["Content-Type"] = "text/html; charset=utf-8"
	ngx.say(html)
end

return consoleUtils