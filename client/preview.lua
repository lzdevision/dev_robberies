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