local props = {
    config_path = "/usr/local/openresty/lualib/flux_gate/core/config.lua",
    resolver_path = "/usr/local/openresty/lualib/flux_gate/core/resolvers",
    db_config = {
        host = "127.0.0.1",
        port = 3306,
        database = "test",
        user = "fluxgate",
        password = "fluxgate",
    }
}
return props