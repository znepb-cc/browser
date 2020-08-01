local history = document.getElementById("history").pages
for i, v in pairs(history) do 
    history:write('<p><a href="' .. v .. '">' .. v .. '</a></p>')
end