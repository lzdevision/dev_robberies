local QBCore = exports['qb-core']:GetCoreObject()
local db = require 'server.database'

local robberies = {}

-- Carrega os roubos do banco quando o resource inicia
AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        db.loadRobberies(function(results)
            for _, r in pairs(results) do
                r.coords = json.decode(r.coords)
                r.propOffset = json.decode(r.propOffset)
                r.anim = json.decode(r.anim)
                r.drops = json.decode(r.drops)
                r.useTarget = r.useTarget == 1
                r.policeCall = r.policeCall == 1
                r.heading = tonumber(r.heading) or 0.0
                robberies[r.label] = r
            end
        end)
    end
end)

-- Envia todos os roubos para o client que solicitou
RegisterNetEvent('dev_robbery:requestRobberies', function()
    TriggerClientEvent('dev_robbery:receiveRobberies', source, robberies)
end)

-- Cria um novo roubo e sincroniza com todos
RegisterNetEvent('dev_robbery:createRobbery', function(data)
    if not QBCore.Functions.HasPermission(source, Config.RequiredPermission) then return end
    data.heading = tonumber(data.heading) or 0.0
    robberies[data.label] = data
    db.insertRobbery(data)
    TriggerClientEvent('dev_robbery:addSingleRobbery', -1, data)
end)

-- Edita um roubo existente
RegisterNetEvent('dev_robbery:editRobbery', function(label, newData)
    if not QBCore.Functions.HasPermission(source, Config.RequiredPermission) then return end
    newData.heading = tonumber(newData.heading) or 0.0
    robberies[label] = newData
    db.updateRobbery(label, newData)
    TriggerClientEvent('dev_robbery:updateRobbery', -1, label, newData)
end)

-- Remove um roubo do banco e do mundo
RegisterNetEvent('dev_robbery:deleteRobbery', function(label)
    if not QBCore.Functions.HasPermission(source, Config.RequiredPermission) then return end
    robberies[label] = nil
    db.deleteRobbery(label)
    TriggerClientEvent('dev_robbery:removeRobbery', -1, label)
end)

-- Dá a recompensa configurada ao jogador
RegisterNetEvent('dev_robbery:giveReward', function(item, amount)
    exports.ox_inventory:AddItem(source, item, amount)
end)

-- Comando para abrir o menu de gerenciamento de roubos
lib.addCommand(Config.Command, {
    help = 'Abrir menu de gerenciamento de roubos',
    restricted = Config.RequiredPermission
}, function(source)
    TriggerClientEvent('dev_robbery:openRobberyMenu', source)
end)