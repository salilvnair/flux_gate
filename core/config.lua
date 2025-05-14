local config = {
  apiConfig = {
    rc1 = {
      old_url = "portdesign",
      old_url_upstream = true,
      resolver_module = "resolvers/gate_resolver",
      new_url_upstream = false,
      data = {
        {
          rules = {
          },
          name = "ASF, PREmdadssad",
          id = "1",
          gate = true,
        },
      },
      active = true,
      new_url = "http://localhost:8888",
    },
  },
  upstreamConfig = {
    {
      upstream = "portdesign",
      id = "",
      servers = {
        {
          id = "1",
          address = "zltv1234:8080",
        },
        {
          id = "2",
          address = "zltv1234:8081",
        },
      },
    },
  },
  urlConfig = {
    {
      id = "rc1",
      subcontext = "/ping",
    },
  },
}

return config
