local robberyCooldowns = {}
local robberyData = {}

local spawnedPropsMap = {}
local spawnedTargets = {} 
local spawnedPropsList = {} 

local currentPreview = nil

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(500)
        TriggerServerEvent('dev_robbery:requestRobberies')
    end
end)

RegisterNetEvent('dev_robbery:receiveRobberies', function(data)
    for _, robbery in pairs(data) do
        robberyData[robbery.label] = robbery
    end

    for _, robbery in pairs(robberyData) do
        spawnProp(robbery)
        spawnTarget(robbery)
    end
end)

function spawnProp(robbery)
    if not robbery or not robbery.prop then
        print("spawnProp: Dados de roubo inválidos.")
        return false
    end

    for i, prop in ipairs(spawnedPropsList) do
        if prop.label == robbery.label then
            if DoesEntityExist(prop.entity) then
                SetEntityAsMissionEntity(prop.entity, true, true)
                DeleteEntity(prop.entity)
            end
            table.remove(spawnedPropsList, i)
            break
        end
    end

    -- print("Spawn heading para", robbery.label, "é", robbery.heading, type(robbery.heading))
    local model = robbery.prop
    local coords = vector3(robbery.coords.x, robbery.coords.y, robbery.coords.z)
    local heading = robbery.heading or 0.0

    local modelHash = type(model) == "number" and model or GetHashKey(model)
    if not IsModelValid(modelHash) then
        -- print("spawnProp: modelo inválido:", model)
        return false
    end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, true, false)
    if not DoesEntityExist(obj) then
        return false
    end

    PlaceObjectOnGroundProperly(obj)
    Wait(0)
    SetEntityHeading(obj, heading + 0.01)
    SetEntityAsMissionEntity(obj, true, true)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)

    table.insert(spawnedPropsList, {
        entity = obj,
        label = robbery.label,
        coords = robbery.coords,
        heading = robbery.heading,
        anim = robbery.anim,
        drops = robbery.drops,
        requiredItem = robbery.requiredItem,
        policeCall = robbery.policeCall
    })

    return true
end

function spawnTarget(robbery)
    if not robbery or not robbery.label then return end
    if spawnedTargets[robbery.label] then return end
    spawnedTargets[robbery.label] = true

    if robbery.useTarget then
        exports.ox_target:addBoxZone({
            name = 'robbery:' .. robbery.label,
            coords = vec3(robbery.coords.x, robbery.coords.y, robbery.coords.z),
            size = vec3(1.5, 1.5, 2.5),
            rotation = robbery.heading or 0.0,
            debug = false,
            options = {
                {
                    name = 'robbery:' .. robbery.label,
                    label = 'Iniciar Roubo',
                    icon = 'fas fa-lock',
                    onSelect = function()
                        startRobbery(robbery)
                    end
                }
            }
        })
    else
        CreateThread(function()
            while true do
                Wait(0)
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local dist = #(coords - vector3(robbery.coords.x, robbery.coords.y, robbery.coords.z))
                
                if dist < 1.5 then
                    lib.showTextUI('[E] Iniciar Roubo')
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        startRobbery(robbery)
                        break
                    end
                else
                    lib.hideTextUI()
                end
            end
        end)
    end
end


function removeRobberyByLabel(label)
    for i, prop in pairs(spawnedPropsList) do
        if prop.label == label then
            if DoesEntityExist(prop.entity) then DeleteEntity(prop.entity) end
            table.remove(spawnedPropsList, i)
            break
        end
    end
    if spawnedTargets[label] then
        exports.ox_target:removeZone('robbery:' .. label)
        spawnedTargets[label] = nil
    end
    robberyData[label] = nil
end

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

function startRobbery(robbery)
    local ped = PlayerPedId()
    if IsEntityDead(ped) then return end

    local label = robbery.label
    local now = GetGameTimer()
    local cooldownTime = (robbery.cooldown or 20) * 60000

    if robberyCooldowns[label] and now < robberyCooldowns[label] then
        local remaining = math.ceil((robberyCooldowns[label] - now) / 1000)
        return lib.notify({ type = "error", description = string.format("Tente novamente em %d segundo(s)", remaining) })
    end

    if robbery.requiredItem and robbery.requiredItem ~= '' then
        local hasItem = exports.ox_inventory:Search('slots', robbery.requiredItem)
        if not hasItem or #hasItem <= 0 then
            return lib.notify({ type = "error", description = "Você precisa de " .. robbery.requiredItem })
        end
    end

    TaskTurnPedToFaceCoord(ped, robbery.coords.x, robbery.coords.y, robbery.coords.z, 1000)
    Wait(300)

    -- print(robbery.policeCall)

    if robbery.policeCall then
        Config.Dispatch()
    end

    local success = lib.progressBar({
        duration = robbery.anim.duration or 10000,
        label = 'Roubando...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict = robbery.anim.dict,
            clip = robbery.anim.name
        }
    })

    if not success then
        return lib.notify({ type = 'error', description = 'Roubo cancelado!' })
    end

    for _, drop in ipairs(robbery.drops) do
        TriggerServerEvent('dev_robbery:giveReward', drop.name, drop.amount)
    end

    robberyCooldowns[label] = GetGameTimer() + cooldownTime
    lib.notify({ type = 'success', description = 'Você recebeu sua recompensa!' })
end

function previewAndPlaceProp(model, callback)
    local heading, created, lastCoords = 0.0, false, nil
    
    lib.requestModel(model)

    CreateThread(function()
        while true do
            local hit, _, coords = lib.raycast.cam(1)
            if hit then
                local pedCoords = GetEntityCoords(PlayerPedId())
                if not created and #(coords - pedCoords) > 1.5 then
                    currentPreview = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
                    SetEntityAlpha(currentPreview, 170, false)
                    SetEntityCompletelyDisableCollision(currentPreview, true)
                    SetEntityCollision(currentPreview, false, false)
                    FreezeEntityPosition(currentPreview, true)
                    lastCoords = coords
                    created = true
                end

                if created and DoesEntityExist(currentPreview) then
                    if #(coords - lastCoords) > 0.05 then
                        SetEntityCoordsNoOffset(currentPreview, coords.x, coords.y, coords.z, false, false, false)
                        PlaceObjectOnGroundProperly(currentPreview)
                        lastCoords = coords
                    end
                    SetEntityHeading(currentPreview, heading)
                end

                lib.showTextUI("[E] Confirmar | [DEL] Cancelar | ←/→ Rotacionar")

                if IsControlPressed(0, 174) then heading -= 2.0 end
                if IsControlPressed(0, 175) then heading += 2.0 end

                if IsControlJustReleased(0, 38) then
                    local pos = GetEntityCoords(currentPreview)
                    local actualHeading = GetEntityHeading(currentPreview)
                    DeleteEntity(currentPreview)
                    lib.hideTextUI()
                    callback({ coords = pos, heading = actualHeading })
                    break
                end

                if IsControlJustReleased(0, 178) then
                    DeleteEntity(currentPreview)
                    lib.hideTextUI()
                    callback(nil)
                    break
                end
            end
            Wait(0)
        end
    end)
end

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
    lib.registerContext({
        id = 'delete_robbery_menu',
        title = 'Deletar Roubo',
        options = options
    })
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
    lib.registerContext({
        id = 'teleport_robbery_menu',
        title = 'Teleportar até Roubo',
        options = options
    })
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


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for label, _ in pairs(spawnedTargets) do
        if spawnedTargets[label] then
            exports.ox_target:removeZone('robbery:' .. label)
            spawnedTargets[label] = nil
        end
    end
    spawnedTargets = {}

    for _, propData in pairs(spawnedPropsList) do
        if propData.entity and DoesEntityExist(propData.entity) then
            SetEntityAsMissionEntity(propData.entity, true, true)
            DeleteEntity(propData.entity)
        end
    end
    spawnedPropsList = {}

    robberyData = {}
    spawnedPropsMap = {}

    if currentPreview and DoesEntityExist(currentPreview) then
        SetEntityAsMissionEntity(currentPreview, true, true)
        DeleteEntity(currentPreview)
        currentPreview = nil
    end
end)
