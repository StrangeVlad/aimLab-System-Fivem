-- Core

if Config.Framework == "esx" then
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "oldqb" then
    QBCore = nil
    TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
end
