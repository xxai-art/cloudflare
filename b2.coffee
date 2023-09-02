#!/usr/bin/env coffee

> ./Cf
  ./Zone

[
  host
  bucket
  prefix # f003 , f004 等等, 浏览可以公开访问的仓库的文件，下载链接的域名前缀
] = process.argv.slice(2)

backblazeb2 = prefix + '.backblazeb2.com'

console.log '\n'+host, '→', 'https://'+backblazeb2+'/'+bucket+'/'

[{id}] = await Cf.GET('?name='+host)

await Promise.all [
  Cf.PUT(
    [
      id
      'rulesets/phases/http_response_headers_transform/entrypoint'
    ]
    rules: [
      action: "rewrite"
      action_parameters:
        headers:
          "Access-Control-Allow-Origin":
            operation: "set"
            value: "*"
          "X-Bz-Upload-Timestamp":
            operation: "remove"
          "accept-ranges":
            operation: "remove"
          "age":
            operation: "remove"
          "date":
            operation: "remove"
          "last-modified":
            operation: "remove"
          "nel":
            operation: "remove"
          "report-to":
            operation: "remove"
          "x-bz-content-sha1":
            operation: "remove"
          "x-bz-file-id":
            operation: "remove"
          "x-bz-file-name":
            operation: "remove"
          "x-cloud-trace-context":
            operation: "remove"
      description: "rmHead"
      expression: "true"
      enabled: true
    ]
  )
  Cf.POST(
    [
      id
      'dns_records'
    ]
    content: backblazeb2
    data: {}
    name: host
    proxiable: true
    proxied: true
    ttl: 1
    type: 'CNAME'
    zone_id: id
    zone_name: host
    comment: ''
    tags: []
  )
  Cf.PUT(
    [
      id
      'rulesets/phases/http_request_transform/entrypoint'
    ]
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
]
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
