local logger = {}

function logger.info(message)
    ngx.log(ngx.INFO, message)
end

function logger.debug(message)
    ngx.log(ngx.DEBUG, message)
end

function logger.error(message)
    ngx.log(ngx.ERR, message)
end

return logger