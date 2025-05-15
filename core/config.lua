local config = {
  apiConfig = {
    rc1 = {
      old_url = "portdesign",
      old_url_upstream = true,
      resolver_module = "resolvers/gate_resolver",
      data = {
        {
          name = "ASF, PREmdadssad",
          rules = {
            {
              operator = "OR",
              key = "sas",
              id = "1",
              value = "asas",
            },
            {
              operator = "OR",
              key = "asas",
              id = "2",
              value = "5555",
            },
            {
              group = {
                {
                  operator = "AND",
                  key = "q",
                  id = "1",
                  value = "1",
                },
                {
                  operator = "AND",
                  key = "z",
                  id = "2",
                  value = "5",
                },
              },
              id = "3",
              operator = "AND",
            },
          },
          id = "1",
          gate = true,
        },
        {
          name = "Premiiur",
          rules = {
            {
              operator = "OR",
              key = "sas",
              id = "1",
              value = "asas",
            },
            {
              operator = "OR",
              key = "asas",
              id = "2",
              value = "5555",
            },
            {
              group = {
                {
                  operator = "AND",
                  key = "q",
                  id = "1",
                  value = "1",
                },
                {
                  operator = "AND",
                  key = "z",
                  id = "2",
                  value = "5",
                },
              },
              id = "3",
              operator = "AND",
            },
          },
          id = "2",
          gate = true,
        },
      },
      new_url_upstream = false,
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
