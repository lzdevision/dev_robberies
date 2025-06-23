spawnedPropsList = spawnedPropsList or {}
spawnedTargets = spawnedTargets or {}
robberyData = robberyData or {}
robberyCooldowns = robberyCooldowns or {}
currentPreview = currentPreview or nil

RegisterNetEvent('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(500)
        TriggerServerEvent('dev_robbery:requestRobberies')
    end
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
        TriggerServerEvent('dev_robbery:giveReward', drop.name, drop.amount, robbery.label)
    end

    robberyCooldowns[label] = GetGameTimer() + cooldownTime
    lib.notify({ type = 'success', description = 'Você recebeu sua recompensa!' })
end



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