local window = {
  alert = function(str)
    local w, h = term.getSize()
    local c, m = w/2, h/2
    local closeButtonStr = " OK "
    paintutils.drawFilledBox(2, m-2, w-1, m+2, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(3, m-1)
    term.write(_G.currentPage .. " says:")
    term.setCursorPos(4, m)
    term.write(str)
    term.setCursorPos((w-#closeButtonStr)-1, m+1)
    term.setBackgroundColor(colors.blue)
    term.write(closeButtonStr)
    while true do
      local e, x, y = os.pullEvent('mouse_click')
      if y == m+1 and x >= (w-#closeButtonStr)-1 and x <= w-2 then
        -- TODO: Actually redraw page
        paintutils.drawFilledBox(2, m-2, w-1, m+2, colors.lightGray)
        break
      end
    end
  end,
  prompt = function(str, pre)
    local w, h = term.getSize()
    local c, m = w/2, h/2
    local closeButtonStr = " OK "
    paintutils.drawFilledBox(2, m-2, w-1, m+2, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(3, m-1)
    term.write(_G.currentPage .. " says:")
    term.setCursorPos(4, m)
    term.write(str)
    term.setCursorPos((w-#closeButtonStr)-1, m+1)
    term.setBackgroundColor(colors.blue)
    term.write(closeButtonStr)
  end
}

local DOM = {}

function DOM:newElement(element)
    setmetatable(element, self)
    self.__index = self
    function self:setContent(content)
        element.content = content
        os.queueEvent("browser_redraw")
    end
    return element
end

local document = {
  getElementById = function(id)
    ccemux.echo(textutils.serialise(_G.pageRoot))
    local function find(tbl)
        if type(tbl) == "table" then
            for i, v in pairs(tbl) do
                if v.id and v.id == id then
                    return v
                elseif v.nodes then
                    find(v.nodes)
                end
            end
        end
    end
    print(find(_G.pageRoot))
    local elem = DOM:newElement(find(_G.pageRoot))
    return elem
    --[[
        document.querySelector('#id')
        document.querySelector('.class')
        document.querySelector('tag')
        document.querySelector('tag[attribute]')

        change content
            -> soft reload
    ]]
  end
}

local lua = {}

function lua:execute(code)
    load(code, "=lua", "t", {
        window = window, document = document, pageRoot = _G.pageRoot
    })()
end

function lua:init(root)
    _G.pageRoot = root
    local function findScripts(tbl)
        for i, v in pairs(tbl) do
            if type(v) == "table" then
                if v.name == "lua" then
                    lua:execute(v.content)
                end
                if v.nodes then
                    findScripts(v.nodes)
                end
            end
        end
    end

    findScripts(root)
end

return lua