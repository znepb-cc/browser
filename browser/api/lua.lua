local DOM = {}

function DOM:newElement(element)
    setmetatable(element, self)
    self.__index = self
    function self:setContent(content)
        element.content = content
        os.queueEvent("browser_redraw")
    end
    function self:appendContent(content)
        element.content = element.content .. content
        os.queueEvent("browser_redraw")
    end
    return element
end

local jsWindow = {
  alert = function(str)
    local w, h = term.getSize()
    local c, m = w/2, h/2
    local closeButtonStr = " Click anywhere to close "
    paintutils.drawFilledBox(1, m-2, w, m+2, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, m-1)
    term.write(_G.currentPage .. " says:")
    term.setCursorPos(3, m)
    term.write(str)
    term.setCursorPos((w-#closeButtonStr), m+1)
    term.setBackgroundColor(colors.red)
    term.write(closeButtonStr)
    os.pullEvent("mouse_click")
    os.queueEvent("browser_redraw")
  end,
  prompt = function(str)
    local w, h = term.getSize()
    local c, m = w/2, h/2
    paintutils.drawFilledBox(1, m-2, w, m+2, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, m-1)
    term.write(_G.currentPage .. " asks:")
    term.setCursorPos(3, m)
    term.write(str)
    paintutils.drawLine(1, m+1, w, m+1, colors.lightGray)
    term.setCursorPos(1, m+1)
    term.setTextColor(colors.black)
    local text = read()
    os.queueEvent("browser_redraw")
    return text
  end,
  confirm = function(str)
    local w, h = term.getSize()
    local c, m = w/2, h/2
    paintutils.drawFilledBox(1, m-2, w, m+2, colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, m-1)
    term.write(_G.currentPage .. " asks:")
    term.setCursorPos(3, m)
    term.write(str)
    term.setCursorPos(w-4, m+1)
    term.write("y/n")
    local state = false
    while true do
        local e, k = os.pullEvent("char")
        if k:lower() == "y" then
            state = true
            term.setCursorPos(w-4, m+1)
            term.setBackgroundColor(colors.green)
            term.write(" y ")
            break
        elseif k:lower() == "n" then
            state = false
            term.setCursorPos(w-4, m+1)
            term.setBackgroundColor(colors.red)
            term.write(" n ")
            break
        end
    end
    sleep(1)
    os.queueEvent("browser_redraw")
    return state
  end,
  console = {
    log = function(str)
        os.queueEvent("browser_log", getfenv())
    end,
    error = function(str)
        os.queueEvent("browser_log_error", getfenv())
    end
  },
  getHistory = function()
    os.queueEvent("browser_history")
    local _, history = os.pullEvent("browser_history_rec")
    return history
  end,
  location = {
    href = _G.currentPage,
    reload = function()
        os.queueEvent("browser_redraw")
    end
  },
  document = {
    getElementById = function(id)
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
  },
  sleep = function(msec)
    sleep(msec / 1000)
  end,
  pageRoot = _G.pageRoot
}

local lua = {}

function lua:execute(code)
    load(code, "=lua", "t", jsWindow)()
end

function lua:init(root)
    _G.pageRoot = root
    jsWindow.pageRoot = root
    local function findScripts(tbl)
        for i, v in pairs(tbl) do
            if type(v) == "table" then
                if v.name == "lua" then
                    if v.content then
                        lua:execute(v.content)
                    end
                end
                if v.nodes then
                    findScripts(v.nodes)
                end
            end
        end
    end

    findScripts(root)
    if head then
            
    end
end

return lua