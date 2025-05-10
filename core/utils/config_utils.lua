
local configUtils = {}
local json = require "cjson"
local props = require("flux_gate/core/settings/props")
local fluxGateService = require("flux_gate/core/service/fluxgate_service")
local logger = require("flux_gate/core/utils/logger")


function configUtils.serialize_table1(tbl, indent)
    indent = indent or ""
    local lines = { "{" }
    local is_array = (#tbl > 0) -- Determine if table is array-like

    for key, value in pairs(tbl) do
        local formatted_key = ""

        if not is_array then
            if type(key) == "string" and key:match("^[%a_][%w_]*$") then
                formatted_key = key .. " = "
            else
                formatted_key = ('["%s"] = '):format(key)
            end
        end

        if type(value) == "table" then
            table.insert(lines, indent .. "  " .. formatted_key .. configUtils.serialize_table1(value, indent .. "  ") .. ",")
        elseif type(value) == "string" then
            table.insert(lines, indent .. "  " .. formatted_key .. '"' .. value .. '",')
        else
            table.insert(lines, indent .. "  " .. formatted_key .. tostring(value) .. ",")
        end
    end

    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
end

-- Function to serialize Lua table into Lua syntax
function configUtils.serialize_table(tbl, indent)
    indent = indent or ""
    local lines = { "{" }
    for key, value in pairs(tbl) do
        local formatted_key
        if type(key) == "string" then
            formatted_key = ('["%s"]'):format(key)
        else
            formatted_key = ("[%s]"):format(key)
        end

        if type(value) == "table" then
            table.insert(lines, indent .. "  " .. formatted_key .. " = " .. configUtils.serialize_table(value, indent .. "  ") .. ",")
        elseif type(value) == "string" then
            table.insert(lines, indent .. "  " .. formatted_key .. ' = "' .. value .. '",')
        else
            table.insert(lines, indent .. "  " .. formatted_key .. " = " .. tostring(value) .. ",")
        end
    end
    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
end

-- Write the Lua table to a file
function configUtils.write_lua_file(file_path, lua_table)
    local file, err = io.open(file_path, "w")
    if not file then
        error("Failed to open Lua file: " .. err)
    end
    file:write("local config = " .. configUtils.serialize_table1(lua_table) .. "\n\nreturn config\n")
    file:close()
end

-- Function to load Lua table from file
function configUtils.load_lua_table(file_path)
    local f, err = loadfile(file_path)
    if not f then
        error("Failed to load file: " .. err)
    end
    return f()
end

function configUtils.lua_2_json()
    local lua_table = configUtils.load_lua_table(props.config_path)
    local json_string = json.encode(lua_table)
    return json_string
end

function configUtils.json_2_lua(json_string)
    local json_table = json.decode(json_string)
    return json_table
end


function configUtils.initLatestConfigFromDb()
    local function preload_cache()
        local fluxgate_shared_dict = ngx.shared.fluxgate_shared_dict

        local configSavedByOtherWorker = fluxgate_shared_dict:get("config_saved")

        if not configSavedByOtherWorker then
            logger.debug("initializing config.")
            local fluxgateConfig = fluxGateService.loadConfig();

            local config_data, err = json.decode(fluxgateConfig.config)
            if not config_data then
                error("Failed to decode configuration JSON: " .. (err or "unknown"))
            end
            local success, err = fluxgate_shared_dict:set("config_saved", true)
            if not success then
                error("Failed to store configuration in shared dictionary: " .. (err or "unknown"))
            end
            configUtils.write_lua_file(props.config_path, config_data)
        else
            logger.debug("Other worker already did initialized config.")
        end
    end
    local ok, err = ngx.timer.at(0, preload_cache)
    if not ok then
        logger.debug("Failed:"..err)
    end
end


return configUtils