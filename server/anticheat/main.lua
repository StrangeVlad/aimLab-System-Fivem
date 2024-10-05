-- Decrypt (Anticheat)

function Decrypt(result)
    local x = result
    if Config.Aimlab_Anticheat then
        x = x - 2 * 81999
        x = (x + 99999) % 99999
        x = x / 62
    end
    return math.floor(x)
end

-- Load Anticheat File

local ac_client = ""

Citizen.CreateThread(function()
    local anticheat_file = io.open(Config.Anticheat_Client_Location, "r")
    ac_client = anticheat_file:read("*a")
    io.close(anticheat_file)
end)

RegisterServerEvent("viber-aimlab:server:LoadAnticheat")
AddEventHandler("viber-aimlab:server:LoadAnticheat", function()
    local src = source
    TriggerClientEvent("viber-aimlab:client:LoadAnticheat", src, ac_client)
end)

-- Anticheat Discord Log

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    
    for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifiers.steam = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            identifiers.license = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            identifiers.live = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            identifiers.xbl  = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifiers.discord = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            identifiers.ip = v
        end
    end

    return identifiers
end

function Discord_Log(webhook,source, color, nameasd)
    if source == nil or GetPlayerName(source) == nil then
        return
    end
   
    local id = ExtractIdentifiers(source);
    if id.xbl == "" then
        id.xbl = "N/A"
    elseif id.live == "" then
        id.live = "N/A"
    elseif id.steam == "" then
        id.steam = "N/A"
    elseif id.license == "" then
        id.license = "N/A"
    elseif id.ip == "" then
        id.ip = "N/A"
    end
    local embed = {{
        ["author"] = {
            ["name"] = nameasd,
            ["icon_url"] = "",
            ["url"] = "https://ak4y.tebex.io/"
        },
        ["color"] = color,
        ["fields"] = {
            { ["name"] = "User Details", ["value"] = "\n**`Name:`** "..GetPlayerName(source).."\n**`Ingame ID:`** "..source.."\n**`IP:`** "..string.gsub(id.ip, "ip:", "").."\n**`Steam:`** "..id.steam.."\n**`License:`** "..id.license.."\n**`Discord:`** <@!"..string.gsub(id.discord, "discord:", "")..">\n**`XBL:`** "..id.xbl.."\n**`Live:`** "..id.live, ["inline"] = true }
        },
        ["footer"] = {
            ["text"] = "",
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        },
    }}
    Citizen.Wait(100)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds  = embed}), { ['Content-Type'] = 'application/json' })
end