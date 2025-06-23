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


-- Menu ox de Criação do roubo.

RegisterNetEvent("dev_robbery:startCreateRobbery", function()
    local modelInput = lib.inputDialog('Escolher Prop', {
        {type = 'input', label = 'Modelo do Prop (ex: prop_ld_int_safe_01)', default = 'prop_ld_int_safe_01', required = true}
    })
    if not modelInput then return end

    local modelName = modelInput[1]
    if not modelName or modelName == '' then
        return lib.notify({ type = 'error', description = 'Nome do modelo inválido.' })
    end
    local modelHash = joaat(modelName)

    previewAndPlaceProp(modelHash, function(posData)
        if not posData then return lib.notify({type = 'error', description = 'Criação cancelada.'}) end

        local input = lib.inputDialog('Criar Roubo', {
            {type = 'input', label = 'Nome do Roubo', required = true},
            {type = 'checkbox', label = 'Usar Target?', default = true},
            {type = 'number', label = 'Cooldown (min)', default = 20},
            {type = 'input', label = 'Dict da Animação', default = 'anim@heists@ornate_bank@grab_cash'},
            {type = 'input', label = 'Clip da Animação', default = 'grab'},
            {type = 'number', label = 'Duração da Animação (ms)', default = 10000},
            {type = 'checkbox', label = 'Chamar Polícia?', default = false},
            {type = 'input', label = 'Item Requerido (opcional)', required = false},
            {type = 'textarea', label = 'Drops (item,quantidade por linha)', required = true}
        })
        if not input then return end

        local drops = {}
        for line in string.gmatch(input[9], "[^\r\n]+") do
            local item, amount = line:match("([^,]+),([^,]+)")
            if item and amount then
                table.insert(drops, { name = item, amount = tonumber(amount) or 1 })
            end
        end

        local data = {
            label = input[1],
            coords = posData.coords,
            heading = posData.heading,
            prop = modelName,
            propOffset = vector3(0, 0, 0),
            useTarget = input[2],
            cooldown = input[3],
            requiredItem = input[8],
            policeCall = input[7],
            anim = { dict = input[4], name = input[5], duration = input[6] },
            drops = drops
        }

        TriggerServerEvent("dev_robbery:createRobbery", data)
    end)
end)

-- Abrir menu de lista para edição de roubos.

RegisterNetEvent('dev_robbery:openEditMenu', function()
    local options = {}
    for _, rob in pairs(spawnedPropsList) do
        local label = rob.label
        local data = robberyData[label]
        if data then
            table.insert(options, {
                title = label,
                event = 'dev_robbery:startEditRobbery',
                args = label
            })
        end
    end
    lib.registerContext({
        id = 'edit_robbery_menu',
        title = 'Editar Roubo',
        options = options
    })
    lib.showContext('edit_robbery_menu')
end)

-- Abrir menu Ox para edição de roubos.

RegisterNetEvent('dev_robbery:startEditRobbery', function(label)
    local robbery = robberyData[label]
    if not robbery then return end

    previewAndPlaceProp(robbery.prop, function(posData)
        if not posData then return lib.notify({type = 'error', description = 'Edição cancelada.'}) end

        local dropsText = ''
        for _, d in ipairs(robbery.drops or {}) do
            dropsText = dropsText .. d.name .. ',' .. d.amount .. '\n'
        end
        
        local input = lib.inputDialog('Editar Roubo', {
            {type = 'number', label = 'Duração da Animação (ms)', default = robbery.anim.duration or 10000, required = true},
            {type = 'textarea', label = 'Drops (item,quantidade por linha)', required = true, default = dropsText}
        })
        
        if not input then return end

        local drops = {}
        for line in string.gmatch(input[2], "[^\r\n]+") do
            local item, amount = line:match("([^,]+),([^,]+)")
            if item and amount then
                table.insert(drops, { name = item, amount = tonumber(amount) or 1 })
            end
        end

        local newData = {
            label = label,
            coords = posData.coords,
            heading = posData.heading,
            anim = {
                dict = robbery.anim.dict,
                name = robbery.anim.name,
                duration = tonumber(input[1])
            },
            drops = drops,
            prop = robbery.prop,
            requiredItem = robbery.requiredItem,
            policeCall = robbery.policeCall,
            useTarget = robbery.useTarget,
            cooldown = robbery.cooldown,
            propOffset = robbery.propOffset or vector3(0,0,0)
        }

        TriggerServerEvent('dev_robbery:editRobbery', label, newData)
    end)
end)

-- Menu em lista para deletar roubos.

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

-- Menu em lista para teleportar em roubos.

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