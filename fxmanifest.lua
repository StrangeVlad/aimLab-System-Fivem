fx_version 'adamant'
games { 'gta5' }
description 'viber-aimlab'
lua54 'yes'

shared_scripts {
  'config.lua',
  -- '@ox_lib/init.lua',
}

client_scripts {
  'client/main.lua',
  'client/no_escrow.lua',
}

server_scripts {
  'server/anticheat/main.lua',
  'server/main.lua',
  'server/no_escrow.lua',
}

ui_page 'html/index.html'

files {
  'html/*.html',
  'html/**/*.*',
  'html/*.*',
  'database/db.json',
}

escrow_ignore {
  'config.lua',
  'client/main.lua',
  'server/main.lua',
  'client/anticheat/main.lua',
  'server/anticheat/main.lua',
  'client/no_escrow.lua',
  'server/no_escrow.lua',
  'stream/qua_aimlab_1.ydr',
  'stream/qua_aimlab_2.ydr',
  'stream/qua_aimlab_3.ydr',
  'stream/qua_aimlab.ytyp'
}
dependency '/assetpacks'