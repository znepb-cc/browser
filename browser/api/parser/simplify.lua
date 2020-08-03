local css = require(".browser.api.parser.css")

local function constructNode(node, index)
    return {
        name = node.name,
        attributes = node.attributes,
        style = {},
        id = node.id,
        i = index,
        classes = node.classes,
        content = {}
    }
end

local function getText(node)
    local notags = node:getcontent()
    for _, parent in pairs(node.nodes) do
        notags = notags:gsub(parent:gettext(), " ")
    end
    return notags
end

local function removeWhitespace(str)
    local r = str:gsub("[\t\n]", "")
    return r
end

local function isJustWhitspace(str)
    if str:gsub("[%s\t\n]", "") == "" then
        return true  
    end
    return false
end

local function parseRoot(root)
    local output = {}
    local head = root("head")[1]
    local body = root("body")[1] or root()

    local text = body:getcontent()

    local output = {}

    local function constructElements(node, index)
        local content = {}

        for i, v in pairs(node.nodes) do
            table.insert(content, constructElements(v, i))
        end

        if not node:getcontent():find("[<>]") then
            table.insert(content, node:getcontent())
        else
            local discoveredText = {}
            local pos = node._openend
            local rootContent = body.root:gettext()
            for i, v in pairs(node.nodes) do
                local content = rootContent:sub(pos + 1, v._openstart - 1)
                if isJustWhitspace(content) == false then
                    table.insert(discoveredText, i, removeWhitespace(content))
                end
                
                pos = v._closeend + 1
            end
            if rootContent:sub(pos - 1, pos) ~= "<" then
                table.insert(discoveredText, #node.nodes + #discoveredText + 1, removeWhitespace(rootContent:sub(pos, node._closestart - 1)))
            end

            for i, v in pairs(discoveredText) do
                table.insert(content, i, v)
            end
        end

        local output = constructNode(node, index)
        output.content = content

        return output
    end

    output = constructElements(body)
    

    --for i, v in pairs()

    --[[--
    {
        head = {
            header stuff...
        },
        body = {
            "text",
            {
                name = "p",
                attributes = {},
                style = {},
                iif = "content",
                content = {
                    "Hello there! This is a ",
                    {
                        name = "strong",
                        attributes = {},
                        style = {},
                        id = "",
                        content = {"test!"}
                    }
                }
            }
        }
    }
    --]]--

    --ccemux.echo(textutils.serialise(output))

    return output
end


return parseRoot