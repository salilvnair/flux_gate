
local fileUtils = {}

-- Function to find Lua files without the .lua extension
function fileUtils.find_lua_files_without_extension(dir_path)
    local lua_files_without_extension = {}
    -- Detect the OS
    local is_windows = jit.os == "Windows"
    local command

    if is_windows then
        command = 'dir /b "' .. dir_path .. '"'
    else
        command = 'ls -1 ' .. dir_path
    end

    -- Execute the command
    local handle, err = io.popen(command)
    if not handle then
        print("Failed to open directory: ", err)
        return
    end

    -- Read each line and filter `.lua` files
    for file in handle:lines() do
        if file:match("%.lua$") then
            -- Remove the `.lua` extension
            local name_without_extension = file:match("(.+)%.lua$")
            table.insert(lua_files_without_extension, name_without_extension)
        end
    end
    handle:close()
    return lua_files_without_extension
end

return fileUtils