local QBCore = exports['qb-core']:GetCoreObject()
local robberies = {}

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        exports.oxmysql:query('SELECT * FROM ??', { Config.RobberyTable }, function(results)
            for _, r in pairs(results) do
                r.coords = json.decode(r.coords)
                r.propOffset = json.decode(r.propOffset)
                r.anim = json.decode(r.anim)
                r.drops = json.decode(r.drops)
                r.useTarget = r.useTarget == 1 or r.useTarget == "1" or r.useTarget == true
                r.policeCall = r.policeCall == 1 or r.policeCall == "1" or r.policeCall == true
                r.heading = tonumber(r.heading) or 0.0
                robberies[r.label] = r
            end
        end)
    end
end)

RegisterNetEvent('dev_robbery:giveReward', function(item, amount)
    local src = source
    exports.ox_inventory:AddItem(src, item, amount)
end)

RegisterNetEvent('dev_robbery:requestRobberies', function()
    local src = source
    TriggerClientEvent('dev_robbery:receiveRobberies', src, robberies)
end)

RegisterNetEvent('dev_robbery:createRobbery', function(data)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.RequiredPermission) then return end

    local label = data.label
    data.heading = tonumber(data.heading) or 0.0
    robberies[label] = data

    exports.oxmysql:insert('INSERT INTO ?? (label, coords, heading, prop, propOffset, useTarget, cooldown, requiredItem, policeCall, anim, drops) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        Config.RobberyTable, label,
        json.encode(data.coords), data.heading, data.prop, json.encode(data.propOffset),
        data.useTarget and 1 or 0, data.cooldown, data.requiredItem, data.policeCall and 1 or 0,
        json.encode(data.anim), json.encode(data.drops)
    })

    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        if player == src then
            TriggerClientEvent('dev_robbery:addSingleRobbery', player, data)
        else
            TriggerClientEvent('dev_robbery:addSingleRobbery', player, data)
        end
    end
end)

RegisterNetEvent('dev_robbery:deleteRobbery', function(label)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.RequiredPermission) then return end

    robberies[label] = nil
    exports.oxmysql:execute('DELETE FROM ?? WHERE label = ?', { Config.RobberyTable, label })
    TriggerClientEvent('dev_robbery:removeRobbery', -1, label)
end)

RegisterNetEvent('dev_robbery:editRobbery', function(label, newData)
    local src = source
    if not QBCore.Functions.HasPermission(src, Config.RequiredPermission) then return end

    newData.heading = tonumber(newData.heading) or 0.0
    robberies[label] = newData

    exports.oxmysql:update([[
        UPDATE ?? 
        SET coords = ?, heading = ?, anim = ?, drops = ?, 
            prop = ?, propOffset = ?, requiredItem = ?, policeCall = ?, 
            useTarget = ?, cooldown = ?
        WHERE label = ?
    ]], {
        Config.RobberyTable,
        json.encode(newData.coords), newData.heading,
        json.encode(newData.anim), json.encode(newData.drops),
        newData.prop, json.encode(newData.propOffset or vector3(0, 0, 0)), newData.requiredItem or '',
        newData.policeCall and 1 or 0, newData.useTarget and 1 or 0,
        newData.cooldown or 0,
        label
    })

    TriggerClientEvent('dev_robbery:updateRobbery', -1, label, newData)
end)


lib.addCommand(Config.Command, {
    help = 'Abrir menu de gerenciamento de roubos',
    restricted = Config.RequiredPermission
}, function(source)
    TriggerClientEvent('dev_robbery:openRobberyMenu', source)
end)
