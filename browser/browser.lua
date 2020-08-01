xpcall(function()
    _G.currentPage = "internal://pages/main.html"

    local parser = require(".browser.api.parser")
    local renderer = require(".browser.api.renderer")
    local lua = require(".browser.api.lua")
  
    local w, h = term.getSize()

    local history = {
        ["pages"] = {},
        ["position"] = 0
    }

    local function loadCurrentPage()
        term.setCursorPos(1, h)
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.gray)
        term.write("Connecting...")
        if currentPage:find("internal://") == 1 then
            if fs.exists("/browser/" .. currentPage:sub(12, #currentPage)) then
                local file = fs.open("/browser/" .. currentPage:sub(12, #currentPage), "r")
                local data = file.readAll()
                file.close()
                local root, head = parser:parseHTML(data)
                table.insert(history["pages"], currentPage)
                lua:init(root, head)

                if history["position"] > 0 then
                    table.remove(history, (#history["pages"] - (history["position"]+1)), #history["pages"])
                    history["position"] = 0
                end

                return root
            else
                local file = fs.open("/browser/pages/errors/404.html", "r")
                local data = file.readAll()
                file.close()
                local root = parser:parseHTML(data)
                lua:init(root)
                return root
            end
        elseif currentPage:find("http://") == 1 or currentPage:find("https://") == 1 then
            local file, err, errorHandle = http.get(currentPage, {
                [ "User-Agent" ] = "CC-Web 1.0"
              })
            if not file then
                if not errorHandle then
                    local root = parser:parseHTML([[<html>
    <body>
        <p>Undetermined error. Check the URL, and then try again.</p>
    </body>
</html>]])
                    return root
                else
                    if fs.exists("/browser/pages/errors/" .. errorHandle.getResponseCode() .. ".html") then
                        local file = fs.open("/browser/pages/errors/" .. errorHandle.getResponseCode() .. ".html", "r")
                        local data = file.readAll()
                        file.close()
                        local root = parser:parseHTML(data)
                        lua:init(root)
                        return root
                    else
                        ccemux.echo(errorHandle.read())
                        local code, ret = errorHandle.getResponseCode()
                        ccemux.echo(tostring(code) .. " " .. tostring(ret))
                        local root = parser:parseHTML([[<html>
    <body>
        <p>]] .. code .. [[ ]] .. ret .. [[</p>
    </body>
</html>]])
                        return root
                    end
                end
            else
                local data = file.readAll()
                file.close()
                local root = parser:parseHTML(data)
                lua:init(root)

                local file = fs.open("testing.html", "w")
                file.write(data)

                file.close()

                table.insert(history["pages"], currentPage)

                if history["position"] > 0 then
                    table.remove(history, (#history["pages"] - (history["position"]+1)), #history["pages"])
                    history["position"] = 0
                end
                return root
            end
        elseif currentPage:find("file://") == 1 then
            ccemux.echo(currentPage:sub(8, #currentPage))
            if fs.exists(currentPage:sub(8, #currentPage)) then
                
                local file = fs.open(currentPage:sub(8, #currentPage), "r")
                local data = file.readAll()
                file.close()
                local root = parser:parseHTML(data)
                lua:init(root)

                table.insert(history["pages"], currentPage)

                if history["position"] > 0 then
                    table.remove(history, (#history["pages"] - (history["position"]+1)), #history["pages"])
                    history["position"] = 0
                end

                return root
            else
                local file = fs.open("/browser/pages/errors/404.html", "r")
                local data = file.readAll()
                file.close()
                local root = parser:parseHTML(data)
                lua:init(root)
                return root
            end
        else
            local file = fs.open("/browser/pages/invalidURL.html", "r")
            local data = file.readAll()
            file.close()
            local root = parser:parseHTML(data)
            lua:init(root)
            return root
        end
    end
  
    local links = {}
  
    --[[local function fancyPrintTable(tbl)
      local function iterate(tbl, amountOfSpaces)
        for i, v in pairs(tbl) do
          if type(v) == "table" then
            print((" "):rep(amountOfSpaces), i .. ": {")
            fancyPrintTable(v, amountOfSpaces + 1)
            print((" "):rep(amountOfSpaces), "}")
          else
            print((" "):rep(amountOfSpaces), i .. ":", v)
          end
        end
      end
  
      iterate(tbl, 0)
    end]]
    --hi

    links = renderer.render(loadCurrentPage())

    while true do
        local e = {os.pullEvent()}
        if e[1] == "mouse_click" then
            local m, x, y = e[2], e[3], e[4]
            if m == 1 then
                if y == 1 then
                    if x >= 5 then
                        term.redirect(term.native())
                        term.setTextColor(colors.gray)
                        paintutils.drawLine(5, 1, w, 1, colors.lightGray)
                        term.setCursorPos(5, 1)
                        _G.currentPage = read()
                        renderer.renderTop()
                        links = renderer.render(loadCurrentPage())
                    end
                else
                    local x, y = x - 1, y - 2
                    for i, v in pairs(links) do
                        if x >= v.startX and x <= v.endX and y == v.y then
                            _G.currentPage = v.href
                            renderer.renderTop()
                            links = renderer.render(loadCurrentPage())
                        end
                    end
                end
            end
        elseif e[1] == "key" then
            local k = e[2]
            if k == keys.f5 then
                links = {}
                links = renderer.render(loadCurrentPage())
            end
        elseif e[1] == "browser_redraw" then
            links = renderer.render(_G.pageRoot)
        elseif e[1] == "browser_log" then
            if type(e[2]) == "string" then
                ccemux.echo(e[2])
            end
        elseif e[1] == "browser_history" then
            os.queueEvent("browser_history_rec", history)
        end
    end
end, function(err)
    term.redirect(term.native())
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    term.clear()
    print(err)
    _G.currentPage = nil
    --print(debug.traceback())
end)