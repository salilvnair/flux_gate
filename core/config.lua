local config = {
  defaultConfig = {
    old_url = "tester",
  },
  apiConfig = {
    rc1 = {
      old_url = "http://127.0.0.1:31337",
      old_url_upstream = false,
      active = true,
      resolver_module = "resolvers/url_resolver",
      new_url_upstream = true,
      data = {
        {
          rules = {
            {
              operator = "AND",
              id = "1",
              key = "Ching",
            },
          },
          id = "1",
          gate = true,
        },
      },
      new_url = "ping_backend_upstream",
    },
  },
  urlConfig = {
    {
      id = "rc1",
      subcontext = "/ping",
    },
  },
  upstreamConfig = {
    {
      upstream = "ping_backend_upstream",
      servers = {
        {
          id = "1",
          address = "localhost:31337",
        },
      },
      id = "",
    },
  },
}

return config
