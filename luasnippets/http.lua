local ls   = require("luasnip")
local s    = ls.snippet
local i    = ls.insert_node
local t    = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

-- fmta uses <> as placeholders, << >> for literal < >
-- {{ and }} are literal braces in the output — perfect for {{variable}} syntax

return {

  -- @var = value
  s("var", fmta("@<name> = <value>", {
    name  = i(1, "baseUrl"),
    value = i(2, "http://localhost:5000"),
  })),

  -- ### separator
  s("sep", t("###")),

  -- GET
  s("get", fmta([[
GET {{<url>}}/<endpoint>
Accept: application/json
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
  })),

  -- GET with Authorization
  s("getauth", fmta([[
GET {{<url>}}/<endpoint>
Accept: application/json
Authorization: Bearer {{<token>}}
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    token    = i(3, "token"),
  })),

  -- POST with JSON body
  s("post", fmta([[
POST {{<url>}}/<endpoint>
Content-Type: application/json
Accept: application/json

{
  <body>
}
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    body     = i(3, '"key": "value"'),
  })),

  -- POST with Authorization + JSON body
  s("postauth", fmta([[
POST {{<url>}}/<endpoint>
Content-Type: application/json
Accept: application/json
Authorization: Bearer {{<token>}}

{
  <body>
}
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    token    = i(3, "token"),
    body     = i(4, '"key": "value"'),
  })),

  -- PUT with JSON body
  s("put", fmta([[
PUT {{<url>}}/<endpoint>/<id>
Content-Type: application/json
Accept: application/json

{
  <body>
}
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    id       = i(3, "id"),
    body     = i(4, '"key": "value"'),
  })),

  -- PATCH with JSON body
  s("patch", fmta([[
PATCH {{<url>}}/<endpoint>/<id>
Content-Type: application/json
Accept: application/json

{
  <body>
}
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    id       = i(3, "id"),
    body     = i(4, '"key": "value"'),
  })),

  -- DELETE
  s("del", fmta([[
DELETE {{<url>}}/<endpoint>/<id>
Accept: application/json
]], {
    url      = i(1, "baseUrl"),
    endpoint = i(2, "api/endpoint"),
    id       = i(3, "id"),
  })),

  -- Authorization header only
  s("auth", fmta("Authorization: Bearer {{<token>}}", {
    token = i(1, "token"),
  })),

  -- JSON headers
  s("json", t({
    "Content-Type: application/json",
    "Accept: application/json",
  })),

  -- Full file setup block
  s("setup", fmta([[
@<urlName> = <urlValue>
@<tokenName> = <tokenValue>

###
]], {
    urlName    = i(1, "baseUrl"),
    urlValue   = i(2, "http://localhost:5000"),
    tokenName  = i(3, "token"),
    tokenValue = i(4, "your-token-here"),
  })),
}
