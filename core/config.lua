local config = {
  apiConfig = {
    sc1 = {
      resolver_module = "resolvers/body_resolver",
      data = {
        {
          rules = {
            {
              operator = "AND",
              key = "JohnDoe",
              id = "1",
            },
          },
          gate = true,
          id = "1",
        },
      },
      active = true,
      new_url = "http://127.0.0.1:54333/CreateUserService",
      old_url_upstream = false,
      old_url = "http://127.0.0.1:54333",
      new_url_upstream = false,
    },
    rc1 = {
      resolver_module = "resolvers/url_resolver",
      data = {
        {
          rules = {
            {
              operator = "AND",
              key = "Ching",
              id = "1",
            },
          },
          gate = false,
          id = "1",
        },
      },
      active = true,
      new_url = "ping_backend_upstream",
      old_url_upstream = false,
      old_url = "http://127.0.0.1:31337",
      new_url_upstream = true,
    },
  },
  urlConfig = {
    {
      subcontext = "/ping",
      id = "rc1",
    },
    {
      subcontext = "/CreateUserService",
      id = "sc1",
    },
  },
  defaultConfig = {
    old_url = "tester",
  },
  upstreamConfig = {
    {
      servers = {
        {
          address = "localhost:31337",
          id = "1",
        },
      },
      upstream = "ping_backend_upstream",
      id = "",
    },
  },
}

return config
