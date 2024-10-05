-- Core

if Config.Framework == "esx" then
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    ESX.PlayerData = ESX.GetPlayerData()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "oldqb" then
    QBCore = nil
    Citizen.CreateThread(function()
        while QBCore == nil do
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end)
end 

-- Join Game | This part is for get Aimlab data as soon as the player join the server.
-- Definitely don't delete!

if Config.Framework == "qb" or Config.Framework == "oldqb" then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent('viber-aimlab:server:checkData')
    end)
elseif Config.Framework == "esx" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function()
        TriggerServerEvent('viber-aimlab:server:checkData')
    end)
end