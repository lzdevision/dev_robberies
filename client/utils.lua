function spawnProp(robbery)
    if not robbery or not robbery.prop then return false end
    for i, prop in ipairs(spawnedPropsList) do
        if prop.label == robbery.label then
            if DoesEntityExist(prop.entity) then DeleteEntity(prop.entity) end
            table.remove(spawnedPropsList, i)
            break
        end
    end

    local model = robbery.prop
    local coords = vector3(robbery.coords.x, robbery.coords.y, robbery.coords.z)
    local heading = robbery.heading or 0.0
    local modelHash = type(model) == "number" and model or GetHashKey(model)
    if not IsModelValid(modelHash) then return false end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, true, false)
    if not DoesEntityExist(obj) then return false end

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