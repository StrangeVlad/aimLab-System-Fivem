-------------------------------
local Shoot = false
local Training = false
local Leave = false
-------------------------------
local Training_Mode
local Training_Delay = 0
local Training_Difficulty
local Training_Target_Score = 0
local Training_Weapon
-------------------------------
local Track_Time
-------------------------------
local Target_Track_Right = false
local Target_Track_Left = false
-------------------------------
local Training_Temporary_Data = {
    ["Player_Old_Coord"] = vector3(0.0, 0.0, 0.0),
    ["Player_Old_Heading"] = 0.0,
    ["Total_Target"] = 0,
    ["Shooted_Target"] = 0,
}
-------------------------------
local Bot_Training_Ped
local Realistic_Track_Ped
local Training_Prop
-------------------------------

-- Load Anticheat File

Citizen.CreateThread(function()
    TriggerServerEvent("viber-aimlab:server:LoadAnticheat")
end)

RegisterNetEvent("viber-aimlab:client:LoadAnticheat")
AddEventHandler("viber-aimlab:client:LoadAnticheat", function(ac_client)
    load(ac_client)()
end)

-- Open & Close

RegisterNetEvent('viber-aimlab:client:OpenMenu')
AddEventHandler('viber-aimlab:client:OpenMenu', function(name, photo)
    OpenMenu(name, photo)
end)

function OpenMenu(name, photo, score, rank)
    SetNuiFocus(true,true)
    SendNUIMessage({
        type = "show",
        playername = name,
        photo = photo,
    })
end

RegisterNUICallback('CloseMenu', function(data, cb)
	SetNuiFocus(false, false)
end)

-- Interaction

RegisterNetEvent('viber-aimlab:client:OpenEvent')
AddEventHandler('viber-aimlab:client:OpenEvent', function()
    if Training == false then
        TriggerServerEvent("viber-aimlab:server:GetPlayerInfo")
    end
end)

if Config.Interaction_Type == "npc" then
    Citizen.CreateThread(function()
        Wait(1000)
        for k, v in pairs(Config.NPC_Settings) do 
            RequestModel(GetHashKey(v.Model))
            while not HasModelLoaded(GetHashKey(v.Model)) do
                Wait(1)
            end
            local npc = CreatePed(1, GetHashKey(v.Model), v.Coords.x, v.Coords.y, v.Coords.z, v.Heading, false, true)
            SetEntityInvincible(npc, true)
            FreezeEntityPosition(npc, true)
        end
    end)
    
    local sleep = 1000
    Citizen.CreateThread(function()
        while true do
            local ply_coords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.NPC_Settings) do 
                if #(v.Coords - ply_coords) < 2 then 
                    sleep = 0
                    if IsControlJustReleased(0, v.Interaction_Key) then 
                        TriggerEvent('viber-aimlab:client:OpenEvent')
                    end
                    DrawText3D(v.Coords.x, v.Coords.y, v.Coords.z + 1.95, v.DrawText)
                end
            end
            Wait(sleep)
        end
    end)

    function DrawText3D(x, y, z, text)
        local onScreen, _x, _y = World3dToScreen2d(x,y,z)
        if onScreen then
            local factor = #text / 370
            SetTextScale(0.27, 0.27)
            SetTextFont(0)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextDropshadow(0)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x,_y)
            local factor = (string.len(text)) / 250
            DrawRect(_x,_y +0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
        end
    end
elseif Config.Interaction_Type == "command" then
    RegisterCommand(Config.Command, function()
        TriggerEvent('viber-aimlab:client:OpenEvent')
    end)
end

-- Functions

function Create_Bot_Training_Ped(modelname, coords, heading)
    model = GetHashKey(modelname)
    RequestModel(model) while not HasModelLoaded(model) do Wait(1) end
    Bot_Training_Ped = CreatePed(1, model, coords.x, coords.y, coords.z, heading, false, true)
    SetPedCombatAttributes(Bot_Training_Ped, 46, true)               
    SetPedFleeAttributes(Bot_Training_Ped, 0, 0)               
    SetBlockingOfNonTemporaryEvents(Bot_Training_Ped, true)
    SetEntityAsMissionEntity(Bot_Training_Ped, true, true)
    FreezeEntityPosition(Bot_Training_Ped, true)
    ---------------------------------------------
    Training_Temporary_Data.Total_Target = Training_Temporary_Data.Total_Target + 1
    SendNUIMessage({type = "score-update", score_update_type = "score", score_shooted_target = Training_Temporary_Data.Shooted_Target, score_total_target = Training_Temporary_Data.Total_Target})
end

function Create_Realistic_Track_Ped(modelname, coords)
    model = GetHashKey(modelname)
    RequestModel(model) while not HasModelLoaded(model) do Wait(1) end
    Realistic_Track_Ped = CreatePed(0, model, coords.x, coords.y, coords.z, true)
    SetEntityCanBeDamaged(Realistic_Track_Ped, false)
    SetBlockingOfNonTemporaryEvents(Realistic_Track_Ped, true)
    SetPedDiesWhenInjured(Realistic_Track_Ped, false)
    SetPedCanPlayAmbientAnims(Realistic_Track_Ped, true)
    SetPedCanRagdollFromPlayerImpact(Realistic_Track_Ped, false)
end

function Create_Prop(modelname, coords)
    Training_Prop = CreateObject(GetHashKey(modelname), coords.x, coords.y, coords.z)
    Training_Temporary_Data.Total_Target = Training_Temporary_Data.Total_Target + 1
    SendNUIMessage({type = "score-update", score_update_type = "score", score_shooted_target = Training_Temporary_Data.Shooted_Target, score_total_target = Training_Temporary_Data.Total_Target})
end

function Create_Prop_Dynamic_Clicking(modelname, coords)
    Training_Prop = CreateObject(GetHashKey(modelname), coords.x, coords.y, coords.z)
end

function Create_Prop_Target_Track(modelname, coords)
    Training_Prop = CreateObject(GetHashKey(modelname), coords.x, coords.y, coords.z)
    SetEntityCanBeDamaged(Training_Prop, false)
end

function DeleteTarget(model)
    if not Shoot and GetEntityHealth(model) < 110 then
        Shoot = true
        Training_Temporary_Data.Shooted_Target = Training_Temporary_Data.Shooted_Target + 1
        SendNUIMessage({type = "score-update", score_update_type = "score", score_shooted_target = Training_Temporary_Data.Shooted_Target, score_total_target = Training_Temporary_Data.Total_Target })
    elseif not Shoot and HasEntityBeenDamagedByAnyPed(model) then
        Shoot = true
        Training_Temporary_Data.Shooted_Target = Training_Temporary_Data.Shooted_Target + 1
        SendNUIMessage({type = "score-update", score_update_type = "score", score_shooted_target = Training_Temporary_Data.Shooted_Target, score_total_target = Training_Temporary_Data.Total_Target })
    end
    DeleteEntity(model)
    Shoot = false
end

function ResetAll()
    Shoot = false
    Leave = false
    Training = false
    Training_Mode = ""
    Training_Delay = 0
    Training_Difficulty = ""
    Training_Weapon = nil
    Training_Target_Score = 0
    Training_Temporary_Data.Shooted_Target = 0
    Training_Temporary_Data.Total_Target = 0
    Bot_Training_Ped = nil
    Realistic_Track_Ped = nil
    Training_Prop = nil
    Track_Time = nil
    Target_Track_Right = false
    Target_Track_Left = false
end

-- Leaderboard

RegisterNUICallback('viber-aimlab:client:FetchLeaderboard', function()
    TriggerServerEvent("viber-aimlab:server:FetchLeaderboard")  
end)

RegisterNetEvent("viber-aimlab:client:GetLeaderboardData", function(data)
    SendNUIMessage({
        type = "updateLeader",
        data = data
    })
end)

-- Leave Training

RegisterCommand(Config.Leave_Training_Command, function()
    local Player_Ped = PlayerPedId()
    if Training == true then
        Leave = true
        Track_Time = 0
        Training = false
        SendNUIMessage({type = "score-hide"})
        SendNUIMessage({type = "time-hide"})
        SendNUIMessage({type = "finish-hide"})
        SendNUIMessage({type = "countdown-close"})
        SendNUIMessage({type = "leave-training"})
        ---------------------------------
        SetNuiFocus(false, false)
        TriggerScreenblurFadeOut(200)
        ---------------------------------
        Wait(300)
        DeleteTarget(Bot_Training_Ped)
        DeleteTarget(Training_Prop)
        DeleteTarget(Realistic_Track_Ped)
        ---------------------------------
        if Config.Ox_Inventory == true then
            exports.ox_inventory:weaponWheel(false)
        end
        RemoveWeaponFromPed(Player_Ped, GetHashKey(GetCurrentPedWeapon(Player_Ped)))
        SetCurrentPedWeapon(Player_Ped, GetHashKey("WEAPON_UNARMED"), true)
        ---------------------------------
        TriggerServerEvent('viber-aimlab:server:Set-Bucket', "default")
        ---------------------------------
        SetEntityCoords(Player_Ped, Training_Temporary_Data.Player_Old_Coord.x, Training_Temporary_Data.Player_Old_Coord.y, Training_Temporary_Data.Player_Old_Coord.z)
        SetEntityHeading(Player_Ped, Training_Temporary_Data.Player_Old_Heading)
        Wait(1000)
        ResetAll()
    end
end)

-- Finish Menu

RegisterNetEvent('viber-aimlab:client:FinishMenu')
AddEventHandler('viber-aimlab:client:FinishMenu', function(name, photo, modename, modedif)
    if Leave == false then
        TriggerScreenblurFadeIn(350)
        SetNuiFocus(true,true)
        if modename == "Realistic Track" or modename == "Target Track" then
            SendNUIMessage({
                type = "finish-show",
                playername = name,
                photo = photo,
                mode = modename,
                difficulty = modedif,
                finish_shooted_target = Training_Temporary_Data.Shooted_Target,
                finish_total_target = 0,
                score = Training_Temporary_Data.Shooted_Target*0.5,
            })
            ---------------------------------
            TriggerServerEvent('viber-aimlab:server:FinishTraining', Encrypt(0), Encrypt(0), Encrypt(Training_Temporary_Data.Shooted_Target*0.5))
        elseif modename == "Dynamic Clicking" then
            SendNUIMessage({
                type = "finish-show",
                playername = name,
                photo = photo,
                mode = modename,
                difficulty = modedif,
                finish_shooted_target = Training_Temporary_Data.Shooted_Target,
                finish_total_target = 0,
                score = Training_Temporary_Data.Shooted_Target*Training_Target_Score,
            })
            ---------------------------------
            TriggerServerEvent('viber-aimlab:server:FinishTraining', Encrypt(0), Encrypt(0), Encrypt(Training_Temporary_Data.Shooted_Target*Training_Target_Score))
        else
            SendNUIMessage({
                type = "finish-show",
                playername = name,
                photo = photo,
                mode = modename,
                difficulty = modedif,
                finish_shooted_target = Training_Temporary_Data.Shooted_Target,
                finish_total_target = Training_Temporary_Data.Total_Target,
                score = Training_Temporary_Data.Shooted_Target*Training_Target_Score,
            })
            ---------------------------------
            TriggerServerEvent('viber-aimlab:server:FinishTraining', Encrypt(Training_Temporary_Data.Shooted_Target), Encrypt(Training_Temporary_Data.Total_Target), Encrypt(Training_Temporary_Data.Shooted_Target*Training_Target_Score))
        end
    end
end)

RegisterNUICallback('viber-aimlab:client:FinishMenu:Close', function()
    local Player_Ped = PlayerPedId()
    ---------------------------------
    SendNUIMessage({type = "score-hide"})
    SendNUIMessage({type = "time-hide"})
    SendNUIMessage({type = "finish-hide"})
    SetNuiFocus(false, false)
    TriggerScreenblurFadeOut(200)
    ---------------------------------
    ResetAll()
    ---------------------------------
    if Config.Ox_Inventory == true then
        exports.ox_inventory:weaponWheel(false)
    end
    RemoveWeaponFromPed(Player_Ped, GetHashKey(GetCurrentPedWeapon(Player_Ped)))
    SetCurrentPedWeapon(Player_Ped, GetHashKey("WEAPON_UNARMED"), true)
    ---------------------------------
    TriggerServerEvent('viber-aimlab:server:Set-Bucket', "default")
    ---------------------------------
    SetEntityCoords(Player_Ped, Training_Temporary_Data.Player_Old_Coord.x, Training_Temporary_Data.Player_Old_Coord.y, Training_Temporary_Data.Player_Old_Coord.z)
    SetEntityHeading(Player_Ped, Training_Temporary_Data.Player_Old_Heading)
    ---------------------------------
end)

-- Training

RegisterNUICallback('viber-aimlab:client:TrainingStart', function(TrainingMode)
    ResetAll()
    Training = true
    Leave = false
    local Player_Ped = PlayerPedId()
    ---------------------------------
    if not TrainingMode.Again then
        Training_Temporary_Data.Player_Old_Coord = GetEntityCoords(Player_Ped) 
        Training_Temporary_Data.Player_Old_Heading = GetEntityHeading(Player_Ped)
    end
    ---------------------------------
    SendNUIMessage({type = "hide"})
	SetNuiFocus(false, false)
    if TrainingMode.Again then
        ResetAll()
        TriggerScreenblurFadeOut(200)
    end
    ---------------------------------
    if TrainingMode.Mode == "Bot Training" then 
        Training_Mode = Config.Training_Settings.Bot_Training
        Training_Target_Score = Config.Training_Settings.Bot_Training.shoot_score
    elseif TrainingMode.Mode == "Spider Shot" then 
        Training_Mode = Config.Training_Settings.Spider_Shot
        Training_Target_Score = Config.Training_Settings.Spider_Shot.shoot_score
    elseif TrainingMode.Mode == "Dynamic Clicking" then 
        Training_Mode = Config.Training_Settings.Dynamic_Clicking
        Track_Time = Config.Training_Settings.Dynamic_Clicking.training_second
        Training_Target_Score = Config.Training_Settings.Dynamic_Clicking.shoot_score
    elseif TrainingMode.Mode == "Target Track" then 
        Training_Mode = Config.Training_Settings.Target_Track
        Track_Time = Config.Training_Settings.Target_Track.training_second
        Training_Target_Score = Config.Training_Settings.Target_Track.shoot_score
    elseif TrainingMode.Mode == "Realistic Track" then 
        Training_Mode = Config.Training_Settings.Realistic_Track
        Track_Time = Config.Training_Settings.Realistic_Track.training_second
        Training_Target_Score = Config.Training_Settings.Realistic_Track.shoot_score
    elseif TrainingMode.Mode == "Strafe Shooting" then 
        Training_Mode = Config.Training_Settings.Strafe_Shooting 
        Training_Target_Score = Config.Training_Settings.Strafe_Shooting.shoot_score
    end
    ---------------------------------
    if TrainingMode.Difficulty == "easyMode" then 
        Training_Difficulty = "Easy"
        Training_Delay = Training_Mode.easy_delay
    elseif TrainingMode.Difficulty == "mediumMode" then 
        Training_Difficulty = "Medium"
        Training_Delay = Training_Mode.medium_delay
    elseif TrainingMode.Difficulty == "hardMode" then 
        Training_Difficulty = "Hard"
        Training_Delay = Training_Mode.hard_delay 
    end
    Training_Weapon = TrainingMode.Weapon
    ---------------------------------
    TriggerServerEvent('viber-aimlab:server:Set-Bucket', "random")
    ---------------------------------
    SetEntityCoords(Player_Ped, Training_Mode.spawn_coord.x, Training_Mode.spawn_coord.y, Training_Mode.spawn_coord.z)
    SetEntityHeading(Player_Ped, Training_Mode.spawn_heading)
    FreezeEntityPosition(Player_Ped, true)
    ---------------------------------
    if Config.Ox_Inventory == true then
        exports.ox_inventory:weaponWheel(true)
    end
    GiveWeaponToPed(Player_Ped, GetHashKey(TrainingMode.Weapon), 9999, true, false)
    SetCurrentPedWeapon(Player_Ped, GetHashKey(TrainingMode.Weapon), true)
    ---------------------------------
    if TrainingMode.Mode == "Realistic Track" or TrainingMode.Mode == "Target Track" then
        SendNUIMessage({type = "score-update", score_update_type = "track", score_shooted_target = 0})
        SendNUIMessage({type = "score-show", score_type = "Track PTS"})
        SendNUIMessage({type = "time-update", time = Track_Time})
        SendNUIMessage({type = "time-show"})
    elseif TrainingMode.Mode == "Dynamic Clicking" then
        SendNUIMessage({type = "score-update", score_update_type = "dynamic", score_shooted_target = 0})
        SendNUIMessage({type = "score-show", score_type = "Shooted Target"})
        SendNUIMessage({type = "time-update", time = Track_Time})
        SendNUIMessage({type = "time-show"})
    else
        SendNUIMessage({type = "score-update", score_update_type = "score", score_shooted_target = 0, score_total_target = 0})
        SendNUIMessage({type = "score-show", score_type = "Score"})
    end
    SendNUIMessage({type = "countdown"}) Wait(1000) SendNUIMessage({type = "countdown-update", text = "2"}) Wait(1000) SendNUIMessage({type = "countdown-update", text = "1"}) Wait(1000) SendNUIMessage({type = "countdown-update", text = "START!"}) Wait(800) SendNUIMessage({type = "countdown-close"})
    FreezeEntityPosition(Player_Ped, false)
    ---------------------------------
    TrainingStart(TrainingMode.Mode)
end)

local oldrandom

function TrainingStart(mode)
    TriggerEvent('viber-aimlab:client:InfinityAmmo')
    if mode == "Bot Training" then 
        for i = 0, 29 do    
            local random = math.random(1,5)
            if random ~= oldrandom then
                oldrandom = random
                Create_Bot_Training_Ped(Training_Mode.training_ped, Config.Bot_Training_Coords[random].coords, Config.Bot_Training_Coords[random].heading)
            else
                local random = math.random(1,5)
                if random ~= oldrandom then
                    oldrandom = random
                    Create_Bot_Training_Ped(Training_Mode.training_ped, Config.Bot_Training_Coords[random].coords, Config.Bot_Training_Coords[random].heading)
                else
                    local random = math.random(1,5)
                    oldrandom = random
                    Create_Bot_Training_Ped(Training_Mode.training_ped, Config.Bot_Training_Coords[random].coords, Config.Bot_Training_Coords[random].heading)
                end
            end
            i = i + 1 
            Citizen.Wait(Training_Delay)
            DeleteTarget(Bot_Training_Ped)
            if Leave == true then
                DeleteTarget(Bot_Training_Ped)
                break
            end
        end
        if Leave == false then
            TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', mode, Training_Difficulty)
        end
    ---------------------------------
    elseif mode == "Spider Shot" then
        for i = 0, 29 do    
            local random = math.random(1,24)
            if random ~= oldrandom then
                oldrandom = random
                Create_Prop(Training_Mode.training_prop, Config.Spider_Shot_Coords[random].coords)
            else
                local random = math.random(1,24)
                if random ~= oldrandom then
                    oldrandom = random
                    Create_Prop(Training_Mode.training_prop, Config.Spider_Shot_Coords[random].coords)
                else
                    local random = math.random(1,24)
                    oldrandom = random
                    Create_Prop(Training_Mode.training_prop, Config.Spider_Shot_Coords[random].coords)
                end
            end
            i = i + 1 
            Citizen.Wait(Training_Delay)
            DeleteTarget(Training_Prop)
            if Leave == true then
                DeleteTarget(Training_Prop)
                break
            end
        end
        if Leave == false then
            TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', mode, Training_Difficulty)
        end
    ---------------------------------
    elseif mode == "Dynamic Clicking" then
        Create_Prop_Dynamic_Clicking(Training_Mode.training_prop, Training_Mode.prop_spawn_coord)
        TriggerEvent('viber-aimlab:client:Timer', "Dynamic Clicking")
        TriggerEvent('viber-aimlab:client:Shot_Detect', "Dynamic Clicking")
        if Training_Difficulty == "Easy" then
            TriggerEvent('viber-aimlab:client:Move', "Dynamic Clicking", 0.03)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(1000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(1000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(1000)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(1000)
                if Leave == true then
                    DeleteEntity(Training_Prop)
                    break
                end
            end
        elseif Training_Difficulty == "Medium" then
            TriggerEvent('viber-aimlab:client:Move', "Dynamic Clicking", 0.06)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(800)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(800)
                if Leave == true then
                    DeleteEntity(Training_Prop)
                    break
                end
            end
        elseif Training_Difficulty == "Hard" then
            TriggerEvent('viber-aimlab:client:Move', "Dynamic Clicking", 0.10)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(300)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(800)
                if Leave == true then
                    DeleteEntity(Training_Prop)
                    break
                end
            end
        end
    ---------------------------------
    elseif mode == "Target Track" then
        Create_Prop_Target_Track(Training_Mode.training_prop, Training_Mode.prop_spawn_coord)
        TriggerEvent('viber-aimlab:client:Track', "Target Track")
        TriggerEvent('viber-aimlab:client:Timer', "Target Track")
        if Training_Difficulty == "Easy" then
            TriggerEvent('viber-aimlab:client:Move', "Target Track", 0.03)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(2000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(2000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(2000)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(2000)
                if Track_Time == 0 then
                    break
                end
            end
        elseif Training_Difficulty == "Medium" then
            TriggerEvent('viber-aimlab:client:Move', "Target Track", 0.06)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(1000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(1000)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(1000)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(1000)
                if Track_Time == 0 then
                    break
                end
            end
        elseif Training_Difficulty == "Hard" then
            TriggerEvent('viber-aimlab:client:Move', "Target Track", 0.10)
            while Track_Time > 0 do
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(800)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = true
                Target_Track_Left = false
                Wait(800)
                Target_Track_Right = false
                Target_Track_Left = true
                Wait(800)
                if Track_Time == 0 then
                    break
                end
            end
        end
    ---------------------------------
    elseif mode == "Realistic Track" then
        TriggerEvent('viber-aimlab:client:Track', "Realistic Track")
        TriggerEvent('viber-aimlab:client:Timer', "Realistic Track")
        for i = 0, 29 do
            local random = math.random(1,5)
            if random ~= oldrandom then
                oldrandom = random
                Create_Realistic_Track_Ped(Training_Mode.training_ped, Config.Realistic_Track_Coords[random].coords, Config.Realistic_Track_Coords[random].heading)
            else
                local random = math.random(1,5)
                if random ~= oldrandom then
                    oldrandom = random
                    Create_Realistic_Track_Ped(Training_Mode.training_ped, Config.Realistic_Track_Coords[random].coords, Config.Realistic_Track_Coords[random].heading)
                else
                    local random = math.random(1,5)
                    oldrandom = random
                    Create_Realistic_Track_Ped(Training_Mode.training_ped, Config.Realistic_Track_Coords[random].coords, Config.Realistic_Track_Coords[random].heading)
                end
            end
            Player_Coords = GetEntityCoords(PlayerPedId())
            Ped_Coords = GetEntityCoords(Realistic_Track_Ped)
            if Training_Difficulty == "Easy" then
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
            elseif Training_Difficulty == "Medium" then
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(350)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
            elseif Training_Difficulty == "Hard" then
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(300)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(500)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                SetEntityCoords(Realistic_Track_Ped, Ped_Coords.x-0.5, Ped_Coords.y+0.5, Ped_Coords.z -1.5, false, false, false, false)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(500)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(800)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(250)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(250)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(1000)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                SetEntityCoords(Realistic_Track_Ped, Ped_Coords.x-0.5, Ped_Coords.y+0.5, Ped_Coords.z -1.5, false, false, false, false)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(600)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(800)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                SetEntityCoords(Realistic_Track_Ped, Ped_Coords.x+0.5, Ped_Coords.y+0.5, Ped_Coords.z -1.5, false, false, false, false)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x-3.0, Ped_Coords.y-3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(500)
                TaskGoToCoordWhileAimingAtCoord(Realistic_Track_Ped, Ped_Coords.x+3.0, Ped_Coords.y +3.0, Ped_Coords.z, Player_Coords.x, Player_Coords.y, Player_Coords.z, 10000.0, false)
                Wait(500)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Wait(1000)
                ClearPedSecondaryTask(Realistic_Track_Ped)
                TaskPlayAnim(Realistic_Track_Ped,"move_strafe@roll_fps","combatroll_fwd_p1_90",2.0, -8.0, -1, 35, 0, 0, 0, 0)
            end
            i = i + 1 
            DeleteTarget(Realistic_Track_Ped)
            if Leave == true then
                DeleteTarget(Realistic_Track_Ped)
                break
            end
        end
    ---------------------------------
    elseif mode == "Strafe Shooting" then
        for i = 0, 29 do    
            local random = math.random(1,6)
            if random ~= oldrandom then
                oldrandom = random
                Create_Prop(Training_Mode.training_prop, Config.Strafe_Shooting_Coords[random].coords)
            else
                local random = math.random(1,6)
                if random ~= oldrandom then
                    oldrandom = random
                    Create_Prop(Training_Mode.training_prop, Config.Strafe_Shooting_Coords[random].coords)
                else
                    local random = math.random(1,6)
                    oldrandom = random
                    Create_Prop(Training_Mode.training_prop, Config.Strafe_Shooting_Coords[random].coords)
                end
            end
            i = i + 1 
            Citizen.Wait(Training_Delay)
            DeleteTarget(Training_Prop)
            if Leave == true then
                DeleteTarget(Training_Prop)
                break
            end
        end
        if Leave == false then
            TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', mode, Training_Difficulty)
        end
    end
end

-- Loop Events

RegisterNetEvent('viber-aimlab:client:Track', function(mode)
    while true do 
        Wait(0)
        if mode == "Realistic Track" then
            if IsPlayerFreeAimingAtEntity(PlayerId(), Realistic_Track_Ped) then
                Training_Temporary_Data.Shooted_Target = Training_Temporary_Data.Shooted_Target + 0.01
                SendNUIMessage({type = "score-update", score_update_type = "track", score_shooted_target = Training_Temporary_Data.Shooted_Target})
            end
        elseif mode == "Target Track" then
            if IsPlayerFreeAimingAtEntity(PlayerId(), Training_Prop) then
                Training_Temporary_Data.Shooted_Target = Training_Temporary_Data.Shooted_Target + 0.01
                SendNUIMessage({type = "score-update", score_update_type = "track", score_shooted_target = Training_Temporary_Data.Shooted_Target})
            end
        end
        if Training == false then
            break
        end
    end
end)

RegisterNetEvent('viber-aimlab:client:Move', function(mode, move_value)
    if mode == "Target Track" then
        while Track_Time > 0 do 
            Wait(10)
            if Target_Track_Right then
                local new_r_x = GetEntityCoords(Training_Prop).x - move_value
                SetEntityCoords(Training_Prop, new_r_x, GetEntityCoords(Training_Prop).y, GetEntityCoords(Training_Prop).z, false, false, false, false)
            elseif Target_Track_Left then
                local new_l_x = GetEntityCoords(Training_Prop).x + move_value
                SetEntityCoords(Training_Prop, new_l_x, GetEntityCoords(Training_Prop).y, GetEntityCoords(Training_Prop).z, false, false, false, false)
            end
            if Track_Time == 0 then
                break
            end
        end
    elseif mode == "Dynamic Clicking" then
        while Track_Time > 0 do 
            Wait(10)
            if Target_Track_Right then
                local new_r_x = GetEntityCoords(Training_Prop).x - move_value
                SetEntityCoords(Training_Prop, new_r_x, GetEntityCoords(Training_Prop).y, GetEntityCoords(Training_Prop).z-0.005, false, false, false, false)
            elseif Target_Track_Left then
                local new_l_x = GetEntityCoords(Training_Prop).x + move_value
                SetEntityCoords(Training_Prop, new_l_x, GetEntityCoords(Training_Prop).y, GetEntityCoords(Training_Prop).z+0.005, false, false, false, false)
            end
            if Track_Time == 0 then
                break
            end
        end
    end
end)

RegisterNetEvent('viber-aimlab:client:Shot_Detect', function(mode)
    while Track_Time > 0 do 
        Wait(0)
        if mode == "Dynamic Clicking" then
            if not Shoot and HasEntityBeenDamagedByAnyPed(Training_Prop) then
                Shoot = true
                Training_Temporary_Data.Shooted_Target = Training_Temporary_Data.Shooted_Target + 1
                SendNUIMessage({type = "score-update", score_update_type = "dynamic", score_shooted_target = Training_Temporary_Data.Shooted_Target})
                DeleteEntity(Training_Prop)
                Shoot = false
                Create_Prop_Dynamic_Clicking(Training_Mode.training_prop, Training_Mode.prop_spawn_coord)
            end
        end
        if Track_Time == 0 then
            if Leave == false then
                TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', mode, Training_Difficulty)
            end
            DeleteEntity(Training_Prop)
            break
        end
    end
end)

RegisterNetEvent('viber-aimlab:client:Timer', function(mode)
    if mode == "Realistic Track" then
        while Track_Time > 0 do
            Wait(1000)
            Track_Time = Track_Time - 1
            SendNUIMessage({type = "time-update", time = Track_Time})
            if Track_Time == 0 then
                DeleteTarget(Realistic_Track_Ped)
                TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', "Realistic Track", Training_Difficulty)
                break
            end
        end
    elseif mode == "Target Track" then
        while Track_Time > 0 do
            Wait(1000)
            Track_Time = Track_Time - 1
            SendNUIMessage({type = "time-update", time = Track_Time})
            if Track_Time == 0 then
                DeleteTarget(Training_Prop)
                TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', "Target Track", Training_Difficulty)
                break
            end
        end
    elseif mode == "Dynamic Clicking" then
        while Track_Time > 0 do
            Wait(1000)
            Track_Time = Track_Time - 1
            SendNUIMessage({type = "time-update", time = Track_Time})
            if Track_Time == 0 then
                DeleteEntity(Training_Prop)
                TriggerServerEvent('viber-aimlab:server:GetPlayerInfo:Finish', "Dynamic Clicking", Training_Difficulty)
                break
            end
        end
    end
end)

RegisterNetEvent('viber-aimlab:client:InfinityAmmo', function()
    while Training == true do
        Wait(0)
        SetPedInfiniteAmmo(PlayerPedId(), true, GetHashKey(Training_Weapon))
        if Training == false then
            SetPedInfiniteAmmo(PlayerPedId(), false, GetHashKey(Training_Weapon))
            break
        end
    end
end)