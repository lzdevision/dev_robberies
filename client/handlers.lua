robberyData = robberyData or {}

RegisterNetEvent('dev_robbery:receiveRobberies', function(data)
    for _, robbery in pairs(data) do
        robberyData[robbery.label] = robbery
        spawnProp(robbery)
        spawnTarget(robbery)
    end
end)

RegisterNetEvent('dev_robbery:addSingleRobbery', function(data)
    robberyData[data.label] = data
    spawnProp(data)
    spawnTarget(data)
end)

RegisterNetEvent('dev_robbery:removeRobbery', function(label)
    removeRobberyByLabel(label)
end)

RegisterNetEvent('dev_robbery:updateRobbery', function(label, data)
    removeRobberyByLabel(label)
    robberyData[label] = data
    spawnProp(data)
    spawnTarget(data)
end)
