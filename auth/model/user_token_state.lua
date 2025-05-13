local userTokenState = {}

function userTokenState.generate(validToken, error, idToken, expiresIn, userInfo)
    return {
        validToken = validToken,
        error = error,
        idToken = idToken,
        expiresIn = expiresIn,
        userInfo = userInfo
        
    }
end
return userTokenState