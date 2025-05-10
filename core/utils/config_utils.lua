
local configUtils = {}
local json = require "cjson"
local props = require("flux_gate/core/settings/props")


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

return configUtils