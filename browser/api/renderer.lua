local w, h = term.getSize()
local bigfont = require("api.bigfont")
local lua = require("api.lua")
local parseCSS = require("api.parser.css")

-- Welcome to ZASHTMLRAPIfCC, or znepb's Absolute Sh*t Hypertext Markup Language Rendering Application Programming Interface for ComputerCraft.
-- Enjoy your stay of useless comments, uncommented code and functions that exist for no reason but are still here because I feel like I'll use them in the future.

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

local function getCSSforElement(css, elementName)
    local output = {}
    if css["*"] then
        for i, v in pairs(css["*"]) do
            output[i] = v
        end
    end

    if css[elementName] then
        for i, v in pairs(css[elementName]) do
            output[i] = v
        end
    end

    return output
end

local function log(text)
    if ccemux then ccemux.echo("[Renderer] " .. text) end
end

local function renderNode(content, x, y, css)
    if not y then error("missing y value") end
    -- CSS variable will define current CSS for the element (sizing, colouture, to allow for `inherit` value.
    -- Some elements will have special functions (script, a, etc) within this function.
    if content then
        -- This is inherited between elements always. This will be changed in the future
        -- If the display tag is set and is "none", don't do anything.
        if not css.display or css.display ~= "none" then
            
            -- Color setting
            if css.color then
                term.setTextColor(colors[css.color])
            end
            if css["background-color"] then
                term.setBackgroundColor(css["background-color"])
            end

            -- Render text
            log("Rendering text: " .. content .. " at " .. tostring(x) .. ", " .. tostring(y))
            local textSize = css["font-size"] or "medium"

            term.setCursorPos(x, y)
            if textSize == "large" then
                bigfont.bigWrite(content)
            else
                write(content)
            end

            -- Display stuff
            if css.display == "inline" or css.display == "inline-block" then
                local eX, eY = term.getCursorPos()
                local link = {
                    sX = x,
                    eX = eX,
                    y = eY
                }
                return eX + 1, eY, link
            elseif css.display == "block" then
                local _, y = term.getCursorPos()
                if textSize == "large" then
                    return 1, y + 3
                else
                    return 1, y + 1
                end
            end
        else
            log("Display is hidden, not rendering")
            return term.getCursorPos()
        end
    else
        log("No content, not rendering")
        return term.getCursorPos()
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
    log("Rendering")
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
    local activeTags = {}

    log("Parsing default.css")
    local file = fs.open("/browser/src/default.css", "r")
    local newContent = file.readAll()
    file.close()

    local css = parseCSS:parse(newContent)

    local function parseNode(content)
        log("Parsing node: " .. content.name)
        for _, node in pairs(content.content) do
            if type(node) == "table" then
                parseNode(node)
            elseif type(node) == "string" then
                log("Rendering node")
                local oX, oY = term.getCursorPos()
                local nx, ny, lpos = renderNode(node, x, y, getCSSforElement(css, content.name))
                x, y = nx, ny
                if content.name == "a" then
                    if content.attributes.href then
                        table.insert(links, {
                            startX = lpos.sX,
                            endX = lpos.eX,
                            y = lpos.y + 2,
                            href = content.attributes.href 
                        })
                    end
                end
            end
        end
    end

    parseNode(content)
    log("Rendering complete")

    return links
end

return {
    render = render,
    renderTop = renderTop
}