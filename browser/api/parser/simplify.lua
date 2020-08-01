local css = require(".browser.api.parser.css")
for i, v in pairs(css("color: red; background-color: light-blue;")) do
    print(i, v)
end

--HAIHAIHAI yo wassu
local function parseNode(node)
    local output
    local ok, err = pcall(function()
        local content = node:getcontent()
        local nodes = node.nodes

        if #nodes > 0 then
            output = {
                name = node.name,
                classes = node.classes,
                attributes = node.attributes,
                id = node.id,
                nodes = {}
            }
            for i, v in pairs(nodes) do
                local openstart = v._openstart - node._openstart - 3
                local closeend = v._closeend - node._openstart - 1

                local preContent = content:sub(1, openstart)
                local postContent = content:sub(closeend, content:len())

                table.insert(output.nodes, {
                    name = "",
                    content = preContent,
                })
                table.insert(output.nodes, parseNode(v))
                table.insert(output.nodes, {
                    name = "",
                    content = postContent
                })
            end
        else
            local style
            if node.attributes.style then
                style = css(node.attributes.style)
            end

            output = {
                name = node.name,
                content = content,
                classes = node.classes,
                style = style,
                attributes = node.attributes,
                id = node.id
            }
        end
    end)
    if not ok then
        return nil, err
    else
        return output
    end
end
  
local function parseRoot(root)
    local content = {}
    local rootElements = {}
    if root("body")[1] then
        rootElements = root("body")[1].nodes
    else
        rootElements = root.nodes
    end
    for i, v in pairs(rootElements) do
        local data, err = parseNode(v)
        if not data then
            return {
                {
                    ["name"] = "p",
                    ["content"] = "Parse error: " .. err
                }
            }
        end
        table.insert(content, data)
    end
    return content
end
  
return parseRoot