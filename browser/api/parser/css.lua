local parser = {}

local function removeWhitespace(str)
    return str:gsub("%s+", "")
end

local longCSS = [[
    a {
        color: blue;
    }

    p {
        display: block;
    }
]]

local function splitCSS(css)
    local split = {}
    for word in string.gmatch(css, ".-:%s?.-;") do
        local out = removeWhitespace(word)
        table.insert(split, out)
    end
    return split
end

local function parseCSSstring(str)
    local keyEnd = str:find(":")
    local valueEnd = str:find(";")
    local key = str:match("^.-:"):sub(1, -2)
    local value = str:match(":.-$"):sub(2, -2)

    -- match start of string up until :
    -- match after : until the ;
    -- remove whitespace
    return key, value
end

local function splitLongCSS(css)
    local split = {}
    for word in string.gmatch(css, ".-%s?{.-}") do
        local out = removeWhitespace(word)
        table.insert(split, out)
    end
    return split
end

local function getSelector(block)
    return removeWhitespace(block):match("^.-{"):sub(1, -2)
end

local function parseBlock(block)
    return parser:parseShorthand(block:gsub("^.-{", ""):gsub("}$", ""))
end

function parser:parseShorthand(css)
    local newCSS = splitCSS(css)
    local output = {}
    for i, v in pairs(newCSS) do
        local out = removeWhitespace(v)
        local key, value = parseCSSstring(out)
        output[key] = value
    end

    return output
end

function parser:parse(css)
    local split = splitLongCSS(css)
    local output = {}

    for i, v in pairs(split) do
        local selector = getSelector(v)
        output[selector] = parseBlock(v)
    end
    --for i, v in pairs(parseBlock(block))
    return output
end

return parser