local config = {
  upstreamConfig = {
    {
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
      upstream = "portdesign",
    },
  },
  urlConfig = {
    {
      id = "rc1",
      subcontext = "/ping",
    },
  },
  apiConfig = {
    rc1 = {
      active = true,
      new_url = "http://localhost:8888",
      old_url = "portdesign",
      old_url_upstream = true,
      resolver_module = "resolvers/gate_resolver",
      data = {
        {
          id = "1",
          name = "ASF, PREmdadssad",
          rules = {
            {
              id = "1",
              value = "asas",
              operator = "OR",
              key = "sas",
            },
            {
              id = "2",
              value = "5555",
              operator = "OR",
              key = "asas",
            },
            {
              id = "3",
              operator = "AND",
              group = {
                {
                  id = "1",
                  value = "1",
                  operator = "AND",
                  key = "q",
                },
                {
                  id = "2",
                  value = "5",
                  operator = "AND",
                  key = "z",
                },
              },
            },
          },
          gate = true,
        },
        {
          id = "2",
          name = "Premiiur",
          rules = {
            {
              id = "1",
              value = "asas",
              operator = "OR",
              key = "sas",
            },
            {
              id = "2",
              value = "5555",
              operator = "OR",
              key = "asas",
            },
            {
              id = "3",
              operator = "AND",
              group = {
                {
                  id = "1",
                  value = "1",
                  operator = "AND",
                  key = "q",
                },
                {
                  id = "2",
                  value = "5",
                  operator = "AND",
                  key = "z",
                },
              },
            },
          },
          gate = true,
        },
      },
      new_url_upstream = false,
    },
  },
}

return config
