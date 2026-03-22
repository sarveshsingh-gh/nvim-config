local ls  = require("luasnip")
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- @var = value declaration
  s("var", fmt("@{} = {}", { i(1, "baseUrl"), i(2, "http://localhost:5000") })),

  -- ### separator
  s("sep", { t("###") }),

  -- GET request
  s("get", fmt([[
GET {{{{{}}}}}/{}
Accept: application/json
]], { i(1, "baseUrl"), i(2, "endpoint") })),

  -- POST with JSON body
  s("post", fmt([[
POST {{{{{}}}}}/{}
Content-Type: application/json
Accept: application/json

{{
{}
}}
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, '  "key": "value"') })),

  -- PUT with JSON body
  s("put", fmt([[
PUT {{{{{}}}}}/{}/{}
Content-Type: application/json
Accept: application/json

{{
{}
}}
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, "id"), i(4, '  "key": "value"') })),

  -- PATCH with JSON body
  s("patch", fmt([[
PATCH {{{{{}}}}}/{}/{}
Content-Type: application/json
Accept: application/json

{{
{}
}}
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, "id"), i(4, '  "key": "value"') })),

  -- DELETE request
  s("del", fmt([[
DELETE {{{{{}}}}}/{}/{}
Accept: application/json
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, "id") })),

  -- Authorization Bearer header
  s("auth", fmt("Authorization: Bearer {}", { i(1, "{{token}}") })),

  -- JSON headers only
  s("json", fmt([[
Content-Type: application/json
Accept: application/json]], {})),

  -- Full request file setup block
  s("setup", fmt([[
@{} = {}
@{} = {}

###
]], { i(1, "baseUrl"), i(2, "http://localhost:5000"), i(3, "token"), i(4, "your-token-here") })),

  -- GET with Authorization
  s("getauth", fmt([[
GET {{{{{}}}}}/{}
Accept: application/json
Authorization: Bearer {{{{{}}}}}
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, "token") })),

  -- POST with Authorization and JSON body
  s("postauth", fmt([[
POST {{{{{}}}}}/{}
Content-Type: application/json
Accept: application/json
Authorization: Bearer {{{{{}}}}}

{{
{}
}}
]], { i(1, "baseUrl"), i(2, "endpoint"), i(3, "token"), i(4, '  "key": "value"') })),
}
