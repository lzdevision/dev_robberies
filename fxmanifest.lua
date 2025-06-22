
fx_version 'cerulean'
games { 'gta5' }

version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua',
    '@qbx_core/modules/playerdata.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
