local config = {
  apiConfig = {
    sc1 = {
      data = {
        {
          id = "1",
          gate = true,
          rules = {
            {
              value = "test",
              id = "1",
              key = "test",
              operator = "AND",
            },
          },
        },
      },
      active = true,
      new_url = "http://localhost:8888/new_ping",
      old_url_upstream = false,
      old_url = "http://localhost:8888/ping",
      new_url_upstream = false,
      resolver_module = "resolvers/body_resolver",
    },
    rc1 = {
      data = {
        {
          id = "1",
          gate = true,
          rules = {
            {
              value = "test",
              id = "1",
              key = "test",
              operator = "AND",
            },
          },
        },
      },
      active = true,
      new_url = "rest_ping",
      old_url_upstream = false,
      old_url = "http://localhost:8888/ping",
      new_url_upstream = true,
      resolver_module = "resolvers/header_resolver",
    },
  },
  upstreamConfig = {
    {
      id = "",
      servers = {
        {
          address = "1.1.1.1",
          id = "1",
        },
        {
          address = "2.2.2.2",
          id = "2",
        },
      },
      upstream = "rest_ping",
    },
  },
  defaultConfig = {
    old_url = "old itdfdf",
  },
  urlConfig = {
    {
      subcontext = "/ping",
      id = "sc1",
    },
    {
      subcontext = "/restping",
      id = "rc1",
    },
  },
}

return config
