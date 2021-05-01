```lua
local http = require "socket.http"

local data = ""

local function collect(chunk)
    if chunk ~= nil then
        data = data .. chunk
    end
    return true
end

local ok, statusCode, headers, statusText = http.request {
    method = "GET",
    url = "http://www.example.com",
    sink = collect
}

print("ok\t", ok);
print("statusCode", statusCode)
print("statusText", statusText)
print("headers:")
for i, v in pairs(headers) do
    print("\t", i, v)
end

print("data", data)
```

运行结果

```
ok              1
statusCode      200
statusText      HTTP/1.1 200 OK
headers:
                content-type    text/html; charset=UTF-8
                accept-ranges   bytes
                connection      close
                cache-control   max-age=604800
                content-length  1256
                etag    "3147526947"
                x-cache HIT
                age     578246
                server  ECS (sjc/16DD)
                expires Mon, 26 Apr 2021 09:42:33 GMT
                last-modified   Thu, 17 Oct 2019 07:18:26 GMT
                vary    Accept-Encoding
                date    Mon, 19 Apr 2021 09:42:33 GMT
data    <!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
    body {
        background-color: #f0f0f2;
        margin: 0;
        padding: 0;
        font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;

    }
    div {
        width: 600px;
        margin: 5em auto;
        padding: 2em;
        background-color: #fdfdff;
        border-radius: 0.5em;
        box-shadow: 2px 3px 7px 2px rgba(0,0,0,0.02);
    }
    a:link, a:visited {
        color: #38488f;
        text-decoration: none;
    }
    @media (max-width: 700px) {
        div {
            margin: 0 auto;
            width: auto;
        }
    }
    </style>    
</head>

<body>
<div>
    <h1>Example Domain</h1>
    <p>This domain is for use in illustrative examples in documents. You may use this
    domain in literature without prior coordination or asking for permission.</p>
    <p><a href="https://www.iana.org/domains/example">More information...</a></p>
</div>
</body>
</html>
```

## 参考

- [sample lua http get](https://gist.github.com/scr1p7ed/f14b9ae1f17646a9a81b)
