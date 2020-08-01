local history = document.getElementById("history").pages
for i, v in pairs(history) do 
    history:appendContent('<p><a href="' .. v .. '">' .. v .. '</a></p>')
end