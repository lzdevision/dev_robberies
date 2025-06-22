RegisterNetEvent('dev_robbery:openRobberyMenu', function()
    lib.registerContext({
        id = 'robbery_menu_main',
        title = 'Gerenciar Roubos',
        options = {
            { title = 'Criar Roubo', icon = 'plus', event = 'dev_robbery:startCreateRobbery' },
            { title = 'Editar Roubo', icon = 'pen', event = 'dev_robbery:openEditMenu' },
            { title = 'Deletar Roubo', icon = 'trash', event = 'dev_robbery:openDeleteMenu' },
            { title = 'Teleportar até Roubo', icon = 'map', event = 'dev_robbery:openTeleportMenu' },
        }
    })
    lib.showContext('robbery_menu_main')
end)

RegisterNetEvent('dev_robbery:openDeleteMenu', function()
    local options = {}
    for _, rob in pairs(spawnedPropsList) do
        table.insert(options, {
            title = rob.label,
            event = 'dev_robbery:confirmDelete',
            args = rob.label
        })
    end
    lib.registerContext({ id = 'delete_robbery_menu', title = 'Deletar Roubo', options = options })
    lib.showContext('delete_robbery_menu')
end)

RegisterNetEvent('dev_robbery:confirmDelete', function(label)
    TriggerServerEvent('dev_robbery:deleteRobbery', label)
end)

RegisterNetEvent('dev_robbery:openTeleportMenu', function()
    local options = {}
    for _, rob in pairs(spawnedPropsList) do
        table.insert(options, {
            title = rob.label,
            event = 'dev_robbery:teleportToRobbery',
            args = rob.label
        })
    end
    lib.registerContext({ id = 'teleport_robbery_menu', title = 'Teleportar até Roubo', options = options })
    lib.showContext('teleport_robbery_menu')
end)

RegisterNetEvent('dev_robbery:teleportToRobbery', function(label)
    for _, rob in pairs(spawnedPropsList) do
        if rob.label == label then
            SetEntityCoords(PlayerPedId(), GetEntityCoords(rob.entity))
            break
        end
    end
end)