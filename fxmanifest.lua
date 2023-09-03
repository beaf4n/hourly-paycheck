fx_version 'cerulean'
game 'gta5'
version '1.0.2'
lua54 'yes'
author 'beaf4n (F4N)'

shared_scripts {
    '@ox_core/imports.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/*.lua'
}