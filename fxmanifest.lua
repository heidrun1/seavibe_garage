fx_version 'cerulean'
game 'gta5'

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
}
client_script 'client.lua'
server_scripts {
    "server.lua",
    '@mysql-async/lib/MySQL.lua',
}


ui_page 'html/index.html'

files {
    "html/index.html",
    "html/style.css",
    "html/engine.png",
}