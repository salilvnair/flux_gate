local mysql = require "resty.mysql"
local logger = require "flux_gate/core/utils/logger"
local json = require "cjson"
local dbUtils = {}

function dbUtils.connect()
    local db, err = mysql:new()
    if not db then
        logger.debug("failed to instantiate mysql: ".. err)
        return
    end

    db:set_timeout(1000) -- 1 sec

    local ok, err, errcode, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "test",
        user = "fluxgate",
        password = "fluxgate",
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }

    if not ok then
        logger.debug("failed to connect: ".. err.. ": ".. errcode.. " ".. sqlstate)
        db:close()
        return
    end

    logger.debug("connected to mysql.")
    return db
end

function dbUtils.fetchConfig(db)
    local res, err, errcode, sqlstate = db:query("SELECT config FROM fluxgate_config", 1)
    if not res then
        logger.debug("bad result: ".. err.. ": ".. errcode.. ": ".. sqlstate.. ".")
        db:close()
        return
    end

    return res
end

function dbUtils.findUserInfo(userId, db)
    local res, err, errcode, sqlstate = db:query("select * from users where user_id='"..userId.."'", 10)
    if not res then
        logger.debug("bad result: ".. err.. ": ".. errcode.. ": ".. sqlstate.. ".")
        db:close()
        return
    end

    return res
end


function dbUtils.saveConfig(config)
    local db = dbUtils.connect()
    if not db then
        return {error = "connection issues"}
    end
    local config_string = json.encode(config)
    local userId = "salilvnair"
    local notes = "Initial configuration"
    local modified_timestamp = os.date("%Y-%m-%d %H:%M:%S")


    -- Prepare the query
    local query = "DELETE FROM fluxgate_config where id = 1"
    local res, err, errcode, sqlstate = db:query(query)
    if not res then
        logger.debug("bad result: ".. err.. ": ".. errcode.. ": ".. sqlstate.. ".")
        db:close()
        return
    end

    -- Prepare the query
    local query = string.format(
        "INSERT INTO fluxgate_config (id, config, modified_timestamp, user_id, notes) VALUES (1, '%s', '%s', '%s', '%s')",
        config_string, modified_timestamp, userId, notes
    )
    local res, err, errcode, sqlstate = db:query(query)
    if not res then
        logger.debug("bad result: ".. err.. ": ".. errcode.. ": ".. sqlstate.. ".")
        db:close()
        return
    end

    return res
end




return dbUtils

