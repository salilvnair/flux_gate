local userInfo = {}

function userInfo.generate(username, firstName, lastName, enabled, roles)
    return {
        username = username,
        firstName = firstName,
        lastName = lastName,
        enabled = enabled,
        roles = roles
        
    }
end
return userInfo