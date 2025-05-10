local config = {
  upstreamConfig = {
    {
      id = "",
      servers = {
        {
          id = "1",
          address = "localhost:31337",
        },
      },
      upstream = "ping_backend_upstream",
    },
  },
  apiConfig = {
    rc1 = {
      active = true,
      new_url = "ping_backend_upstream",
      old_url = "http://127.0.0.1:31337",
      old_url_upstream = false,
      resolver_module = "resolvers/url_resolver",
      new_url_upstream = true,
      data = {
        {
          id = "1",
          rules = {
            {
              id = "1",
              operator = "AND",
              key = "Ching",
            },
          },
          gate = false,
        },
      },
    },
    sc1 = {
      active = true,
      new_url = "http://127.0.0.1:54333/CreateUserService",
      old_url = "http://127.0.0.1:54333",
      old_url_upstream = false,
      resolver_module = "resolvers/body_resolver",
      new_url_upstream = false,
      data = {
        {
          id = "1",
          rules = {
            {
              id = "1",
              operator = "AND",
              key = "JohnDoe",
            },
          },
          gate = true,
        },
      },
    },
  },
  urlConfig = {
    {
      id = "rc1",
      subcontext = "/ping",
    },
    {
      id = "sc1",
      subcontext = "/CreateUserService",
    },
  },
  defaultConfig = {
    old_url = "tester",
  },
}

return config
