local userInfo = {}

function userInfo.generate(username, firstName, lastName, active, roles)
    return {
        username = username,
        firstName = firstName,
        lastName = lastName,
        active = active,
        roles = roles
    }
end

function userInfo.generateRole(id, name)
    return {
        id = id,
        name = name
    }
end

return userInfo