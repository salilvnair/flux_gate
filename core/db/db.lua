local mysql = require("resty.mysql")
local logger = require("flux_gate/core/utils/logger")

local Database = {}
Database.__index = Database

function Database:new(db_config)
    local db, err = mysql:new()
    if not db then
        logger.error("Failed to instantiate mysql: " .. (err or "unknown error"))
        return nil, "MySQL instance creation failed"
    end

    db:set_timeout(1000)

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
        logger.error("Failed to connect: " .. err .. " (" .. errno .. ", " .. sqlstate .. ")")
        db:close()
        return nil, "MySQL connection failed"
    end

    logger.debug("Connected to MySQL.")
    local obj = { db = db }
    setmetatable(obj, self)
    return obj
end

function Database:execute(query, params)
    if not self.db then
        error("Database connection is not initialized.")
    end

    if params then
        for _, param in ipairs(params) do
            local safe_param = self:escape(param)
            query = query:gsub("?", safe_param, 1)
        end
    end

    logger.debug("Executing query: " .. query)
    local res, err, errno, sqlstate = self.db:query(query)
    if not res then
        error("Query failed: " .. err .. " (" .. errno .. ", " .. sqlstate .. ")")
    end
    return res
end

function Database:escape(value)
    if type(value) == "string" then
        return ngx.quote_sql_str(value)
    end
    return tostring(value)
end

function Database:close()
    if self.db then
        local ok, err = self.db:set_keepalive(10000, 50)
        if not ok then
            logger.error("Failed to set keepalive: " .. (err or "unknown"))
            self.db:close()
        end
    end
end

return Database
