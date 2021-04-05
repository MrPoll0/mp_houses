RegisterNetEvent("james_motels:keyTransfered")
AddEventHandler("james_motels:keyTransfered", function(keyData)
    table.insert(cachedData["keys"], keyData)

    ESX.ShowNotification("Has recibido una llave.", "error", 3500)
end)

AddKey = function(keyData)
    if not keyData["id"] then return end
    if not keyData["label"] then keyData["label"] = "Llave" end

    keyData["uuid"] = UUID()

    ESX.TriggerServerCallback("mp_houses:addKey", function(added)
        if added then
            table.insert(cachedData["keys"], keyData)

            ESX.ShowNotification("Llave recibida.", "warning", 3500)
        end
    end, keyData)
end

RemoveKey = function(keyUUID)
    if not keyUUID then return end

    for keyIndex, keyData in ipairs(cachedData["keys"]) do
        if keyData["uuid"] == keyUUID["uuid"] then
            ESX.TriggerServerCallback("james_motels:removeKey", function(removed)
                if removed then
                    table.remove(cachedData["keys"], keyIndex)

                    ESX.ShowNotification("Llave eliminada.", "error", 3500)
                else
                    ESX.ShowNotification("Llave no existente.")
                end
            end, keyUUID["uuid"])

            return
        end
    end
end

TransferKey = function(keyData, newPlayer)
    if not keyData["uuid"] then return end

    for keyIndex, currentKeyData in ipairs(cachedData["keys"]) do
        if keyData["uuid"] == currentKeyData["uuid"] then
            ESX.TriggerServerCallback("james_motels:transferKey", function(removed)
                if removed then
                    table.remove(cachedData["keys"], keyIndex)

                    ESX.ShowNotification("Llave entregada.", "error", 3500)
                else
                    ESX.ShowNotification("Llave no existente")
                end
            end, keyData, GetPlayerServerId(newPlayer))

            return
        end
    end
end

HasKey = function(keyId)
    if not keyId then return end

    for keyIndex, keyData in ipairs(cachedData["keys"]) do
        if keyData["id"] == keyId then
            return true
        end
    end

    return false
end

ShowKeyMenu = function()
    local menuElements = {}

    if #cachedData["keys"] == 0 then return ESX.ShowNotification("No tienes llaves.", "error", 3000) end

    for keyIndex, keyData in ipairs(cachedData["keys"]) do
        table.insert(menuElements, {
            ["label"] = keyData["label"],
            ["key"] = keyData
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "key_main_menu", {
        ["title"] = "Llavero",
        ["align"] = Config.AlignMenu,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local currentKey = menuData["current"]["key"]

        if not currentKey then return end

        menuHandle.close()


        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "key_submain", {
            ["title"] = "Llavero",
            ["align"] = Config.AlignMenu,
            ["elements"] = {
                {
                    ["label"] = "Dar llave.",
                    ["action"] = "give"
                },
                {
                    ["label"] = "Tirar llave.",
                    ["action"] = "delete"
                }
            }
        }, function(menuData2, menuHandle2)
            local currentAction2 = menuData2["current"]["action"]

            menuHandle2.close()

            if currentAction2 == "give" then 
                ConfirmGiveKey(currentKey, function(confirmed)
                    if confirmed ~= nil and confirmed ~= false and confirmed ~= 'no' then
                        TransferKey(currentKey, confirmed)

                        DrawBusySpinner("Dando llave...")

                        Citizen.Wait(1000)

                        RemoveLoadingPrompt()
                    else
                        ESX.ShowNotification("No estás cerca de nadie.")
                    end

                    ShowKeyMenu()
                end)
            end
            if currentAction2 == "delete" then 
                RemoveKey(currentKey)

                DrawBusySpinner("Eliminando llave...")

                Citizen.Wait(1000)

                RemoveLoadingPrompt()

                ShowKeyMenu()
            end

                
        end, function(menuData2, menuHandle2)
            menuHandle2.close()
        end)
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

local function GetPlayers()
    local players = {}

    for _,player in ipairs(GetActivePlayers()) do
        if NetworkIsPlayerActive(player) then
            table.insert(players, player)
        end
    end

    return players
end

local function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

ConfirmGiveKey = function(keyData, callback)
    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestPlayerDistance > 3.0 then 
        return ESX.ShowNotification('No estás cerca de nadie.')
    end
    --[[ 
    local nop = false
    for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      if ped ~= PlayerPedId() then
          local coords = GetEntityCoords(ped)
          local distance = GetDistanceBetweenCoords(coords, GetEntityCoords(PlayerPedId()))
          if distance < 3.0 then
            closestPlayer = player
            closestPlayerDistance = distance
          else
            nop = true 
        end
      end
    end
    ]]

    Citizen.CreateThread(function()
        while ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "main_accept_key") do
            Citizen.Wait(5)

            local cPlayerPed = GetPlayerPed(closestPlayer)

            if DoesEntityExist(cPlayerPed) then
                DrawScriptMarker({
					["type"] = 2,
					["pos"] = GetEntityCoords(cPlayerPed) + vector3(0.0, 0.0, 1.2),
					["r"] = 0,
					["g"] = 0,
					["b"] = 255,
					["sizeX"] = 0.3,
					["sizeY"] = 0.3,
					["sizeZ"] = 0.3,
                    ["rotate"] = true,
                    ["bob"] = true
				})
            end
        end
    end)

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_accept_key", {
            ["title"] = "¿Quieres entregar esta llave?",
            ["align"] = Config.AlignMenu,
            ["elements"] = {
                {
                    ["label"] = "Sí, entregar llave.",
                    ["action"] = "yes"
                },
                {
                    ["label"] = "No, cancelar.",
                    ["action"] = "no"
                }
            }
        }, function(menuData, menuHandle)
            local action = menuData["current"]["action"]
            
            menuHandle.close()

            if action == "yes" then
                callback(closestPlayer)
            else
                callback(false)
            end
        end, function(menuData, menuHandle)
            menuHandle.close()
        end)
end