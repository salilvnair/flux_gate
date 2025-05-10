local mysql = require("resty.mysql")
local logger = require("flux_gate/core/utils/logger")

-- Database connection manager
local Database = {}
Database.__index = Database

function Database:new(db_config)
    local db, err = mysql:new()
    if not db then
        logger.debug("failed to instantiate mysql: ".. err)
        return
    end
    db:set_timeout(1000) -- 1 second timeout

    local ok, err, errno, sqlstate = db:connect({
        host = db_config.host,
        port = db_config.port,
        database = db_config.database,
        user = db_config.user,
        password = db_config.password,
        charset = "utf8",
        max_packet_size = 1024 * 1024
    })

    if not ok then
        logger.debug("failed to connect: ".. err.. ": ".. errno.. " ".. sqlstate)
        db:close()
        return
    end

    logger.debug("connected to mysql.")

    local obj = { db = db }
    setmetatable(obj, self)
    return obj
end

function Database:execute(query, params)
    if params then
        -- Replace `?` placeholders with sanitized values
        for _, param in ipairs(params) do
            local safe_param = self:escape(param)
            query = query:gsub("?", safe_param, 1)
        end
    end
    logger.debug("execute query: ".. query)
    local res, err, errno, sqlstate = self.db:query(query)
    if not res then
        error("Query execution failed: ".. err.. ": ".. errno.. " ".. sqlstate)
    end

    return res
end

function Database:escape(value)
    if type(value) == "string" then
        return ngx.quote_sql_str(value) -- Escape strings safely
    end
    return tostring(value)
end

function Database:close()
    local ok, err = self.db:set_keepalive(10000, 50)
    if not ok then
        error("Failed to set keepalive: " .. err)
    end
end

return Database