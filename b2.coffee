#!/usr/bin/env coffee

> ./Cf
  ./Zone

[
  host
  bucket
  prefix # f003 , f004 等等
] = process.argv.slice(2)

[{id}] = await Cf.GET('?name='+host)

console.log 'host', host, id

console.log await Cf.PUT(
  [
    id
    'rulesets/phases/http_request_transform/entrypoint'
  ].join('/')
  {
  rules:[
    action: "rewrite"
    action_parameters:
      uri:
        path:
          expression: 'concat("/file/'+bucket+'/", http.request.uri.path)'
    description: 'b2'
    expression: 'true'
    enabled: true
  ]
  }
)
# # 定义 URL 和请求内容（payload）
# url = "https://api.cloudflare.com/client/v4/zones/#{ZONE_ID}/rulesets"
#
# # 定义请求头
# headers =
#   'Authorization': "Bearer #{CLOUDFLARE_API_TOKEN}"
#   'Content-Type': 'application/json'
#
# # 发送 POST 请求
# postRequest = async ->
#   try
#     response = await fetch url,
#       method: 'POST'
#       headers: headers
#       body: JSON.stringify payload
#     data = await response.json()
#     console.log
#
# main = =>
#   for i from await Cf.GET()
#     {name, id} = i
#     console.log name
#     {
#       argo
#       settings
#     } = Zone(id)
#
#     # https://developers.cloudflare.com/api
#
#     ON = 'on'
#     OFF = 'off'
#
#     await Promise.all [
#       argo.tiered_caching ON
#       # 关闭浏览器检查防止出现验证码
#       settings.browser_check OFF
#       settings.security_level 'essentially_off'
#       settings.challenge_ttl 31536000
#       settings.ssl 'strict'
#     ]
#
#   return
#
# await main()
