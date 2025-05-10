local file_path = "/usr/local/openresty/lualib/flux_gate/console/index.html"
local base_url = "http://localhost:9090"

-- Read the index.html file
local file = io.open(file_path, "w")
if not file then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("Could not read index.html")
    return
end

local content = file:read("*all")

print(content)