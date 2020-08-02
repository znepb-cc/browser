local history = getHistory().pages
local historyContent = document.getElementById("history")
for i, v in pairs(history) do 
    console.log(v)
    historyContent:appendContent('<p><a href="' .. v .. '">' .. v .. '</a></p>')
end