local config = {
  upstreamConfig = {
    {
      id = "",
      servers = {
        {
          id = "1",
          address = "1.1.1.1",
        },
        {
          id = "2",
          address = "2.2.2.2",
        },
      },
      upstream = "rest_ping",
    },
  },
  apiConfig = {
    rc1 = {
      resolver_module = "resolvers/header_resolver",
      new_url_upstream = true,
      data = {
        {
          id = "1",
          rules = {
            {
              id = "1",
              operator = "AND",
              value = "test",
              key = "test",
            },
          },
          gate = true,
        },
      },
      new_url = "rest_ping",
      old_url_upstream = false,
      old_url = "http://localhost:8888/ping",
      active = true,
    },
    sc1 = {
      resolver_module = "resolvers/body_resolver",
      new_url_upstream = false,
      data = {
        {
          id = "1",
          rules = {
            {
              id = "1",
              operator = "AND",
              value = "test",
              key = "test",
            },
          },
          gate = true,
        },
      },
      new_url = "http://localhost:8888/new_ping",
      old_url_upstream = false,
      old_url = "http://localhost:8888/ping",
      active = true,
    },
  },
  defaultConfig = {
    old_url = "old itdfdf",
  },
  urlConfig = {
    {
      id = "sc1",
      subcontext = "/ping",
    },
    {
      id = "rc1",
      subcontext = "/restping",
    },
  },
}

return config
