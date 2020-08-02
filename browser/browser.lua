xpcall(function()
    _G.currentPage = "internal://pages/main.html"

    local parser = require(".browser.api.parser")
    local renderer = require(".browser.api.renderer")
    local lua = require(".browser.api.lua")
    local resolvePath = require(".browser.api.resolvePath")
  
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

        local data, err = resolvePath(currentPage)
        if data then
            table.insert(history["pages"], currentPage)
            local root = parser:parseHTML(data)
            lua:init(root, head)

            if history["position"] > 0 then
                table.remove(history, (#history["pages"] - (history["position"]+1)), #history["pages"])
                history["position"] = 0
            end

            return root
        else

            local root = parser:parseHTML([[
                <html>
                    <body>
                        <p>Error</p>
                    </body>
                </html>
            ]])
            
            return root
        end
    end
  
    local links = {}
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
                if ccemux then
                    ccemux.echo(e[2])
                end
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
    print(err)
    if ccemux then ccemux.echo(err) end
    _G.currentPage = nil
    --print(debug.traceback())
end)