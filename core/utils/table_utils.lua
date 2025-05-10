local tableUtils = {}

-- Function to check if a table contains a key with a specific value
function tableUtils.containsKeyWithValue(obj, key, value)
    if type(obj) == "table" then
        for k, v in pairs(obj) do
            if k == key and tostring(v):match(value) then
                return true
            end
        end
    end
    return false
end

-- Function to check if a table contains a key
function tableUtils.containsKey(obj, key)
    if type(obj) == "table" then
        for k, _ in pairs(obj) do
            if k == key then
                return true
            end
        end
    end
    return false
end

-- Sort the table
function tableUtils.sort(t, key)
    table.sort(t, function(a, b)
        return a[key] > b[key]
    end)
end

return tableUtils