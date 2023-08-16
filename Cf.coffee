#!/usr/bin/env coffee

{CLOUDFLARE_KEY,CLOUDFLARE_EMAIL} = process.env

export default new Proxy(
  {}
  get:(_, method)=>
    (url, body)=>
      api_url = "https://api.cloudflare.com/client/v4/zones"
      if url
        api_url += ('/'+url)
      data = {
        method
        headers: {
          'X-Auth-Email': CLOUDFLARE_EMAIL
          'X-Auth-Key': CLOUDFLARE_KEY
          'Content-Type': 'application/json'
        }
      }
      if body
        data.body = JSON.stringify(body)
      text = await (
        await fetch(
          api_url
          data
        )
      ).text()
      try
        r = JSON.parse(text)
        if r.success
          return r.result
      throw new Error(text)
      return
)

