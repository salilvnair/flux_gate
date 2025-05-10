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
        file:write(content)
        file:close() 
        -- Cache the replaced content for subsequent requests
        fluxgate_shared_dict:set("index_config_initialized", true)
        fluxgate_shared_dict:set("cached_index", content)
    end
end

return consoleUtils