local oidcTokenResponse = {}

function oidcTokenResponse.generate(id_token, access_token, refresh_token, token_type, expires_in, error, error_description, token_generated)
    return {
        id_token = id_token,
        access_token = access_token,
        refresh_token = refresh_token,
        token_type = token_type,
        expires_in = expires_in,
        error = error,
        error_description = error_description,
        token_generated = token_generated
    }
end
return oidcTokenResponse