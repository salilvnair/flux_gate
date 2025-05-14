local config = {
  apiConfig = {
    rc1 = {
      data = {
        {
          rules = {
            {
              key = "sas",
              id = "1",
              value = "asas",
              operator = "OR",
            },
            {
              key = "asas",
              id = "2",
              value = "5555",
              operator = "OR",
            },
            {
              group = {
                {
                  key = "q",
                  id = "1",
                  value = "1",
                  operator = "AND",
                },
                {
                  key = "z",
                  id = "2",
                  value = "5",
                  operator = "AND",
                },
              },
              id = "3",
              operator = "AND",
            },
          },
          id = "1",
          gate = true,
          name = "ASF, PREmdadssad",
        },
        {
          rules = {
            {
              key = "sas",
              id = "1",
              value = "asas",
              operator = "OR",
            },
            {
              key = "asas",
              id = "2",
              value = "5555",
              operator = "OR",
            },
            {
              group = {
                {
                  key = "q",
                  id = "1",
                  value = "1",
                  operator = "AND",
                },
                {
                  key = "z",
                  id = "2",
                  value = "5",
                  operator = "AND",
                },
              },
              id = "3",
              operator = "AND",
            },
          },
          id = "2",
          gate = true,
          name = "Premiiur",
        },
      },
      active = true,
      new_url = "http://localhost:8888",
      old_url = "portdesign",
      old_url_upstream = true,
      resolver_module = "resolvers/gate_resolver",
      new_url_upstream = false,
    },
  },
  upstreamConfig = {
    {
      id = "",
      servers = {
        {
          address = "zltv1234:8080",
          id = "1",
        },
        {
          address = "zltv1234:8081",
          id = "2",
        },
      },
      upstream = "portdesign",
    },
  },
  urlConfig = {
    {
      subcontext = "/ping",
      id = "rc1",
    },
  },
}

return config
