local props = {
    authUri = "http://localhost:31333/login?test=1234",
    tokenUri = "http://127.0.0.1:31333/authenticate",
    stateMetadata = "FLUX_GATE_STATE",
    clientId = "mockey-oidc",
    clientSecret = "a700122354sdsd",
    codeVerifier = "FluxGate",
    grantType = "authorization_code",
    redirectUri = "http://localhost:4200",
    codeChallenge = "94cj1234",
    hostName = "http://localhost:31333",
    jksSiteUrl = "http://localhost:31333/jwks",
    appBasicAuth = {
        username = "flux_gate",
        password = "Apple2019@"
    }

}
return props