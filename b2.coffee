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
