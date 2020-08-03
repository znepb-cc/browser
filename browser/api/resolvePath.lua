local function resolve(path)
    if path:find("internal://") == 1 then
        if fs.exists("/browser" .. path:sub(12, #path)) then
            local file = fs.open("/browser" .. path:sub(12, #path), "r")
            local data = file.readAll()
            file.close()

            return data
        else
            return nil, {
                ErrorCode = 404,
                ErrorName = "Not Found"
            }
        end
    elseif path:find("http://") == 1 or path:find("https://") == 1 then
        local file, err, errorHandle = http.get(path)
        if not file then
            if not errorHandle then
                return nil, {
                    ErrorCode = 0,
                    ErrorName = "Undetermined"
                }
            else
                if fs.exists("/browser/pages/errors/" .. errorHandle.getResponseCode() .. ".html") then
                    local file = fs.open("/browser/pages/errors/" .. errorHandle.getResponseCode() .. ".html", "r")
                    local data = file.readAll()
                    file.close()
                    return data
                else
                    local code, ret = errorHandle.getResponseCode()
                    return nil, {
                        ErrorCode = code,
                        ErrorName = ret
                    }
                end
            end
        else
            local data = file.readAll()
            file.close()

            return data
        end
    elseif path:find("file://") == 1 then
        if fs.exists(currentPage:sub(8, #currentPage)) then
            local file = fs.open(currentPage:sub(8, #currentPage), "r")
            local data = file.readAll()
            file.close()

            return data
        else
            return nil, {
                ErrorCode = 404,
                ErrorName = "Not Found"
            }
        end
    else
        return nil, {
            ErrorCode = 400,
            ErrorName = "Bad Request"
        }
    end
end

return resolve