local cssParser = require("/browser/api/parser/css")
local htmlParser = require("/browser/api/parser/html")
local jsParser = require("/browser/api/parser/js")
--local extHandler = require("extHandler") or {}
local simplify = require("/browser/api/parser/simplify")

local module = {}


function module:parseCSS(css)
    return cssParser(css)
end

function module:parseHTML(html)
    return simplify(htmlParser.parse(html))
end

function module:parseJS(js)
    -- do
end

return module