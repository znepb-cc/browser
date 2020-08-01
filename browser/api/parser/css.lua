local function removeWhitespace(str)
    return str:sub(#str:match(" *") + 1, #str - #str:match(" *$"))
end

local function splitCSS(css)
    local split = {}
    for word in string.gmatch(css, ".-: .-;") do
        table.insert(split, removeWhitespace(word))
    end
    return split
end

local function parseCSSstring(str)
    local keyEnd = str:find(":")
    local valueEnd = str:find(";")
    local key = str:sub(1, keyEnd - 1)
    local value = str:sub(keyEnd + 2, valueEnd - 1)

    -- match start of string up until :
    -- match after : until the ;
    -- remove whitespace
    return key, value
end

local function parse(css)
    local newCSS = splitCSS(css)
    local output = {}
    for i, v in pairs(newCSS) do
        local key, value = parseCSSstring(v)
        output[key] = value
    end

    return output
end

return parse