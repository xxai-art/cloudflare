#!/usr/bin/env coffee

> ./Cf
  ./Zone

main = =>
  for i from await Cf.GET()
    {name, id} = i
    console.log name
    {
      argo
      settings
    } = Zone(id)

    # https://developers.cloudflare.com/api

    ON = 'on'
    OFF = 'off'

    await Promise.all [
      argo.tiered_caching ON
      # 关闭浏览器检查防止出现验证码
      settings.browser_check OFF
      settings.security_level 'essentially_off'
      settings.challenge_ttl 31536000
    ]

  return

await main()
