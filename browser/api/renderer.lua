local w, h = term.getSize()
local bigfont = require("api.bigfont")
local lua = require("api.lua")

local function loadStyle(style)
    if style then
        if style.color then
            term.setTextColor(colors[style.color])
        end
        if style["background-color"] then
            term.setBackgroundColor(colors[style["background-color"]])
        end
    end
end

local function renderNode(node, x, y)
    if not y then error("missing y value") end
    if node.content then
        if node.name == "h2" then
            term.setTextColor(colors.black)
            term.setCursorPos(x, y)
            loadStyle(node.style)
            bigfont.bigWrite(node.content)
            return 1, y + 3
        elseif node.name == "p" then
            term.setTextColor(colors.gray)
            term.setCursorPos(x, y)
            loadStyle(node.style)
            print(node.content)
            local x, y = term.getCursorPos()
            return 1, y
        elseif node.name == "strong" then
            term.setTextColor(colors.black)
            term.setCursorPos(x, y)
            loadStyle(node.style)
            write(node.content)
            return term.getCursorPos()
        elseif node.name == "br" then
            ccemux.echo("br")
            return 1, y + 1
        elseif node.name == "a" then
            term.setTextColor(colors.blue)
            term.setCursorPos(x, y)
            loadStyle(node.style)
            write(node.content)
            local eX, eY = term.getCursorPos()
            return 2, y + 1, {
                startX = x,
                y = y,
                endX = eX,
                href = node.attributes.href
            }
        elseif node.name == "hr" then
            local w = term.getSize()
            term.setTextColor(colors.lightGray)
            term.setCursorPos(1, y + 1)
            loadStyle(node.style)
            term.write(("\140"):rep(w))
            return 1, y + 2
        elseif node.name == "li" then
            term.setTextColor(colors.gray)
            term.setCursorPos(2, y)
            loadStyle(node.style)
            term.write("\7 " .. node.content)
            return 2, y + 1
        elseif node.name == "lua" then
            
        elseif node.name == "script" then
            --TODO: create warning
            --warning("This is a script, be caucious")
        else
            term.setTextColor(colors.gray)
            term.setCursorPos(x or 1, y or 1)
            loadStyle(node.style)
            write(node.content)
            ccemux.echo(node.content)
            return term.getCursorPos()
        end
    elseif node.nodes then
        for i, v in pairs(node.nodes) do
            x, y = renderNode(v, x, y)
        end

        if node.name == "p" then
            x = 1
            y = y + 1
        end

        return x, y
    end
end

local contentWindow = window.create(term.current(), 2, 3, w - 2, h - 3)

local function renderTop()
    term.redirect(term.native())
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lightGray)
    term.clearLine()
    term.write("< > ")
    paintutils.drawLine(6, 1, w, 1, colors.lightGray)
    term.setCursorPos(5, 1)
    term.setTextColor(colors.gray)
    term.write(_G.currentPage)
end

local function render(content)
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.gray)
    term.write("Parsing...")
    renderTop()

    local links = {}
    
    local pos = 0

    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.white)
    term.write("Parsing...   ")
    renderTop()

    term.redirect(contentWindow)

    term.setBackgroundColor(colors.white)
    term.clear()

    local x, y = 1, 1

    for _, node in pairs(content) do
        local oX, oY = x, y
        x, y, newLink = renderNode(node, x, y)
        if not x then x = oX end
        if not y then y = oY end 
        if newLink then
            table.insert(links, newLink)
        end
    end
    return links
end

return {
    render = render,
    renderTop = renderTop
}