local resolver = require "resty.dns.resolver"
local logger = require "flux_gate/core/utils/logger"
local dnsUtils = {}

-- Function to parse /etc/resolv.conf and get the nameservers
function dnsUtils.allNameServers()
    local resolvers = {}
    local file = io.open("/etc/resolv.conf", "r")
    if not file then
        return nil, "Failed to open /etc/resolv.conf"
    end

    for line in file:lines() do
        -- local nameserver = line:match("^nameserver%s+([%d%.]+)")
        -- logger.debug("Found nameserver: " .. (nameserver or "nil"))
        -- if nameserver then
        --     table.insert(resolvers, nameserver)
        -- end
        if line:match("^nameserver%s+(%S+)") then
            local nameserver = line:match("^nameserver%s+(%S+)")
            if nameserver and nameserver:match("^%d+%.%d+%.%d+%.%d+$") then  -- IPv4 only
                logger.debug("Found nameserver: " .. (nameserver or "nil"))
                table.insert(resolvers, nameserver)
            else
                logger.debug("Skipping non-IPv4 nameserver: ".. tostring(nameserver))
            end
        end
    end
    file:close()

    if #resolvers == 0 then
        return nil, "No nameservers found in /etc/resolv.conf"
    end

    return resolvers
end

-- Function to create a DNS resolver using the nameservers from /etc/resolv.conf
function dnsUtils.generate()
    local resolvers, err = dnsUtils.allNameServers()
    if not resolvers then
        return nil, "Error retrieving resolvers: " .. (err or "unknown error")
    end

    local dns, err = resolver:new{
        nameservers = resolvers,
        retrans = 5,       -- Retry count
        timeout = 2000,    -- Timeout in milliseconds
    }

    if not dns then
        return nil, "Error creating resolver: " .. (err or "unknown error")
    end

    return dns
end

function dnsUtils.resolveHost(host)
    local dns = dnsUtils.generate()
    if not dns then
        return nil, "Error creating resolver"
    end
    local ip, err = dns:query(host, { qtype = resolver.TYPE_A })
    if not ip then
        return nil, "Error resolving IP: " .. (err or "unknown error")
    end
    if ip.errcode then
        return nil, "Error resolving IP: " .. ip.errcode .. ": " .. (ip.errstr or "unknown error")
    end
    if #ip > 0 then
        return ip[1].address
    else
        return nil, "No IP address found"
    end
end

return dnsUtils