GlobalFunction = function(event, data)
    local options = {
        event = event,
        data = data
    }

    TriggerServerEvent("james_motels:globalEvent", options)
end

Init = function()
    FadeIn(500)

    ESX.TriggerServerCallback("mp_houses:getIdentifier", function(identifier)
        if identifier then 
            playerIdentifier = identifier 
        end
    end)

    ESX.TriggerServerCallback("james_motels:fetchMotels", function(fetchedMotels, fetchedStorages, fetchedFurnishings, fetchedKeys, fetchedName)
        if fetchedMotels then
            cachedData["houses"] = fetchedMotels
        end

        if fetchedStorages then
            cachedData["storages"] = fetchedStorages
        end

        if fetchedFurnishings then
            cachedData["furnishings"] = fetchedFurnishings
        end

        if fetchedKeys then
            cachedData["keys"] = fetchedKeys
        end

        if fetchedName then
            ESX.PlayerData["character"] = fetchedName
        end

        CheckIfInsideMotel()
    end)
end

OpenMotelRoomMenu = function(motelRoom)
    local menuElements = {}

    local cachedMotelRoom = cachedData["houses"][motelRoom]

    if cachedMotelRoom then
        for roomIndex, roomData in ipairs(cachedMotelRoom["rooms"]) do
            local roomData = roomData["motelData"]

            local allowed = HasKey("house-" .. roomData["uniqueId"])

            table.insert(menuElements, {
                ["label"] = allowed and "Entrar en el apartamento de " .. roomData["displayLabel"] or "El apartamento de " .. roomData["displayLabel"] .. " está cerrado, picar.",
                ["action"] = roomData,
                ["allowed"] = allowed
            })
        end
    end

    if #menuElements == 0 then
        table.insert(menuElements, {
            ["label"] = "Este apartamento está vacío."
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_motel_menu", {
        ["title"] = "Apartamento",
        ["align"] = Config.AlignMenu,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local action = menuData["current"]["action"]
        local allowed = menuData["current"]["allowed"]

        if action then
            menuHandle.close()

            local doorPos
            for k,v in ipairs(Config.Houses) do 
            	if v.name == motelRoom then 
            		doorPos = v.pos
            	end
            end

            if allowed and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), doorPos) < 5.0 then
                EnterMotel(action)
            elseif not allowed then 
                PlayAnimation(PlayerPedId(), "timetable@jimmy@doorknock@", "knockdoor_idle")

                GlobalFunction("knock_motel", action)
            else
            	ESX.ShowNotification("Achanta hater")
            	menuHandle.close()
            end
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

function getClosestPlayers(tCoords)
	local playersInArea = {}
	local players = ESX.Game.GetPlayers()
    for i=1, #players do 
    	local ped = GetPlayerPed(players[i])
    	local coords = GetEntityCoords(ped)
    	local distance     = GetDistanceBetweenCoords(tCoords, coords.x, coords.y, coords.z, true)

	    if distance <= 5.0 then
	      table.insert(playersInArea, players[i])
	    end
	    return playersInArea
	end
end

OpenInviteMenu = function(motelRoomData)
    local menuElements = {}
    local noOne = false

    local doorPos 
    for k,v in ipairs(Config.Houses) do 
        if v.name == motelRoomData["room"] then 
            doorPos = v.pos
        end
    end

    local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer(doorPos)

    if closestPlayers == -1 or closestPlayerDistance > 5.0 then 
        return ESX.ShowNotification('No hay nadie en la puerta. (si es un error, prueba a comprar una llave extra y dársela)')
    end
    --[[ 
    print(doorPos)
    local closestPlayers, closestPlayerDistance = ESX.Game.GetClosestPlayer(doorPos)
    print(closestPlayers)
    print(closestPlayerDistance)

    if closestPlayers == -1 or closestPlayerDistance > 5.0 then 
       	return ESX.ShowNotification('No hay nadie en la puerta. (si es un error, prueba a comprar una llave extra y dársela)')
    end

    --local closestPlayers = getClosestPlayers(doorPos)
    ]]
    --[[ 
    for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      if ped ~= PlayerPedId() then
          local coords = GetEntityCoords(ped)
          print(player)
          print(ped)
          print("----- "..coords)
          print("::::: "..doorPos)
          local distance = GetDistanceBetweenCoords(coords, doorPos)
          if distance < 3.0 then
          	print("A")
            table.insert(closestPlayers, player)
       	  end
      end
    end
    ]]
    print(GetPlayerServerId(closestPlayer))

	    ESX.TriggerServerCallback("james_motels:retreivePlayers", function(playersRetreived)
	        if playersRetreived then
	            for playerIndex, playerData in ipairs(playersRetreived) do
	                table.insert(menuElements, {
	                    ["label"] = playerData["firstname"] .. " " .. playerData["lastname"],
	                    ["action"] = playerData
	                })

	                ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_motel_invite", {
	                    ["title"] = "Invitar a alguien.",
	                    ["align"] = Config.AlignMenu,
	                    ["elements"] = menuElements
	                }, function(menuData, menuHandle)
	                    local action = menuData["current"]["action"]
	            
	                    if action then
	                        menuHandle.close()

	                        GlobalFunction("invite_player", {
	                            ["house"] = motelRoomData,
	                            ["player"] = action
	                        })
	                    end
	                end, function(menuData, menuHandle)
	                    menuHandle.close()
	                end)
	            end
	        else
	            ESX.ShowNotification("No se ha podido recoger la información de los jugadores.", "error", 3500)
	        end
	    end, GetPlayerServerId(closestPlayer))
end

EnterMotel = function(motelRoomData)
    local exitPos, wardrobePos, invitePos
    for i=1, #Config.Houses do 
        if Config.Houses[i].name == motelRoomData["room"] then 
            exitPos = Config.Houses[i].exit
            wardrobePos = Config.Houses[i].wardrobe
            invitePos = Config.Houses[i].invite
        end
    end
    local interiorLocations = {["exit"] = exitPos, ["wardrobe"] = wardrobePos, ["invite"] = invitePos}

    FadeOut(500)

    EnterInstance(motelRoomData["uniqueId"])

    Citizen.Wait(500)

    ESX.Game.Teleport(PlayerPedId(), interiorLocations["exit"] - vector3(0.0, 0.0, 0.0001), function()
        cachedData["currentHouse"] = motelRoomData

        Citizen.Wait(3000)

        PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", false)

        TriggerEvent('mp:inHouse', true)

        FadeIn(500)
    end)

    Citizen.CreateThread(function()
        local ped = PlayerPedId()

        local UseAction = function(action)
            if action == "exit" then
                FadeOut(500)
                local doorPos
                for k,v in ipairs(Config.Houses) do 
                	if v.name == motelRoomData["room"] then 
                		doorPos = v.pos
                	end
                end

                ESX.Game.Teleport(PlayerPedId(), doorPos - vector3(0.0, 0.0, 0.985), function()
                    ExitInstance()
            
                    FadeIn(500)

                    TriggerEvent('mp:inHouse', false)

                    PlaySoundFrontend(-1, "BACK", "HUD_AMMO_SHOP_SOUNDSET", false)

                    cachedData["currentHouse"] = false
                end)
            elseif action == "wardrobe" then
                OpenWardrobe()
            elseif action == "invite" then
                OpenInviteMenu(motelRoomData)
            end
        end

        while #(GetEntityCoords(ped) - interiorLocations["exit"]) < 50.0 do
            local sleepThread = 500

            local pedCoords = GetEntityCoords(ped)

            for action, actionCoords in pairs(interiorLocations) do
                local dstCheck = #(pedCoords - actionCoords)

                if dstCheck <= 2.0 then
                    sleepThread = 5

                    local displayText = Config.ActionLabel[action]

                    if dstCheck <= 0.9 then
                        displayText = "[~g~E~s~] " .. displayText

                        if IsControlJustPressed(0, 38) then
                            UseAction(action)
                        end
                    end

                    DrawScriptText(actionCoords, displayText)
                end
            end

            Citizen.Wait(sleepThread)
        end
    end)
end

Do = function(b, a)
    if b ~= false then 
        ownedRoom = b 
        owned = true
        ownedMotel = a
    end
end

GetSomething = function(name)
    for doorIndex, doorData in pairs(cachedData["houses"]) do
        for roomIndex, roomData in ipairs(doorData["rooms"]) do
            local roomData = roomData["motelData"]
            
            local allowed = roomData["displayLabel"] == ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]

            local a
            local b

            if allowed then
                cachedData["cachedRoom"] = roomData

                a = roomData

                for k,v in pairs(a) do 
                    if k == "room" then 
                        b = v
                    end 
                end

                if name == b then 
                    Do(b, a)
                elseif name == "Shop" then
                    Furn(b, a)
                else 
                    Do(false, false)
                end
            end
        end
    end
end

OpenLandLord = function(LandLordData)
    local menuElements = {}

    GetSomething(LandLordData.name)

    if owned and ownedRoom == LandLordData.name then 
        if LandLordData.exception == false then
            table.insert(menuElements, {
                ["label"] = "Vender tu apartamento: "..LandLordData.name.." | "..('<span style="color:orange;">%s€</span>'):format(100),
                ["action"] = "sell"
            })
        end

        table.insert(menuElements, {
            ["label"] = "Comprar una llave extra para tu apartamento: "..LandLordData.name.." | "..('<span style="color:green;">%s€</span>'):format(150),
            ["action"] = "buy_key"
        })
    else
        if LandLordData.exception == true then 
            table.insert(menuElements, {
                ["label"] = "Comprar el apartamento VIP: "..LandLordData.name.." | "..('<span style="color:yellow;">%sA</span>'):format(LandLordData.price),
                ["value"] = LandLordData,
                ["action"] = "buy"
            })
        else
            table.insert(menuElements, {
                ["label"] = "Comprar el apartamento: "..LandLordData.name.." | "..('<span style="color:lightgreen;">%s€</span>'):format(LandLordData.price),
                ["value"] = LandLordData,
                ["action"] = "buy"
            })
        end
    end
    
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_motel_landlord", {
        ["title"] = "Inmobiliaria",
        ["align"] = Config.AlignMenu,
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local action = menuData["current"]["action"]

        if action == "buy" then
            local motelRoom = menuData["current"]["value"]

            OpenConfirmBox(motelRoom)
        elseif action == "sell" then
            RemoveKey("house-" .. ownedMotel["uniqueId"])
            ESX.TriggerServerCallback("mp_houses:sellHouse", function(sold)
                if sold then
                    ESX.ShowNotification("Has vendido tu apartamento.")
                    if ownedMotel["room"] == LandLordData.name then 
                        ownedMotel = nil
                    end
                    if ownedRoom == LandLordData.name then 
                        ownedRoom = nil 
                    end
                end
            end, ownedMotel)
        elseif action == "buy_key" then
            ESX.TriggerServerCallback("james_motels:checkMoney", function(approved)
                if approved then
                    AddKey({
                        ["id"] = "house-" .. ownedMotel["uniqueId"],
                        ["label"] = "Apartamento: " .. ownedMotel["room"] .. " - " .. ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]
                    })
                else
                    ESX.ShowNotification("No tienes dinero suficiente para comprar otra llave.")
                end
            end)
        end

        menuHandle.close()
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)

end

OpenConfirmBox = function(motelRoom)
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_accept_motel", {
        ["title"] = "¿Quieres comprar el apartamento: " .. motelRoom.name .. "?",
        ["align"] = Config.AlignMenu,
        ["elements"] = {
            {
                ["label"] = "Sí, confirmar compra.",
                ["action"] = "yes"
            },
            {
                ["label"] = "No, cancelar.",
                ["action"] = "no"
            }
        }
    }, function(menuData, menuHandle)
        local action = menuData["current"]["action"]

        if action == "yes" then
            ESX.TriggerServerCallback("mp_houses:buyHouse", function(bought, uuid)
                if bought then
                    if motelRoom.exception then 
                        ESX.ShowNotification("Has comprado el apartamento VIP: " .. motelRoom.name)
                    else
                        ESX.ShowNotification("Has comprado el apartamento: " .. motelRoom.name)
                    end

                    AddKey({
                        ["id"] = "house-" .. uuid,
                        ["label"] = "Apartamento: " .. motelRoom.name .. " - " .. ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]
                    })
                elseif bought == false and motelRoom.exception then 
                    ESX.ShowNotification("No tienes suficientes arkoins para comprar este apartamento VIP.")
                else
                    ESX.ShowNotification("No tienes dinero suficiente para comprar este apartamento.")
                end

                menuHandle.close()
            end, motelRoom)
        else
            menuHandle.close()
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

OpenWardrobe = function()
	ESX.TriggerServerCallback("james_motels:getPlayerDressing", function(dressings)
		local menuElements = {}

		for dressingIndex, dressingLabel in ipairs(dressings) do
		    table.insert(menuElements, {
                ["label"] = dressingLabel, 
                ["outfit"] = dressingIndex
            })
		end

		ESX.UI.Menu.Open("default", GetCurrentResourceName(), "motel_main_dressing_menu", {
			["title"] = "Vestidor",
			["align"] = Config.AlignMenu,
			["elements"] = menuElements
        }, function(menuData, menuHandle)
            local currentOutfit = menuData["current"]["outfit"]

			TriggerEvent("skinchanger:getSkin", function(skin)
                ESX.TriggerServerCallback("james_motels:getPlayerOutfit", function(clothes)
                    TriggerEvent("skinchanger:loadClothes", skin, clothes)
                    TriggerEvent("esx_skin:setLastSkin", skin)

                    TriggerEvent("skinchanger:getSkin", function(skin)
                        TriggerServerEvent("esx_skin:save", skin)
                    end)
                    
                    ESX.ShowNotification("Te has cambiado de Outfit.")
                end, currentOutfit)
			end)
        end, function(menuData, menuHandle)
			menuHandle.close()
        end)
	end)
end

GetPlayerMotel = function()
    if not ESX.PlayerData["character"] then return end

    if GetGameTimer() - cachedData["lastCheck"] < 5000 then
        return cachedData["cachedRoom"] or false
    end

    cachedData["lastCheck"] = GetGameTimer()

    for doorIndex, doorData in pairs(cachedData["houses"]) do
        for roomIndex, roomData in ipairs(doorData["rooms"]) do
	        local roomData = roomData["motelData"]
    
            local allowed = roomData["displayLabel"] == ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]

            if allowed then
                cachedData["cachedRoom"] = roomData

                return roomData
            end
        end
    end

    cachedData["cachedRoom"] = nil
    return false
end

Dialog = function(title, cb)
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), tostring(title), {
        ["title"] = title,
    }, function(dialogData, dialogMenu)
        dialogMenu.close()
  
        if dialogData["value"] then
            cb(dialogData["value"])
        end
    end, function(dialogData, dialogMenu)
        dialogMenu.close()
    end)
end

DrawScriptMarker = function(markerData)
    DrawMarker(markerData["type"] or 1, markerData["pos"] or vector3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, markerData["sizeX"] or 1.0, markerData["sizeY"] or 1.0, markerData["sizeZ"] or 1.0, markerData["r"] or 1.0, markerData["g"] or 1.0, markerData["b"] or 1.0, 100, markerData["bob"] and true or false, true, 2, false, false, false, false)
end

DrawScriptText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords["x"], coords["y"], coords["z"])
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

PlayAnimation = function(ped, dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

CreateAnimatedCam = function(camIndex)
    local camInformation = camIndex

    if not cachedData["cams"] then
        cachedData["cams"] = {}
    end

    if cachedData["cams"][camIndex] then
        DestroyCam(cachedData["cams"][camIndex])
    end

    cachedData["cams"][camIndex] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(cachedData["cams"][camIndex], camInformation["x"], camInformation["y"], camInformation["z"])
    SetCamRot(cachedData["cams"][camIndex], camInformation["rotationX"], camInformation["rotationY"], camInformation["rotationZ"])

    return cachedData["cams"][camIndex]
end

HandleCam = function(camIndex, secondCamIndex, camDuration)
    if camIndex == 0 then
        RenderScriptCams(false, false, 0, 1, 0)
        
        return
    end

    local cam = cachedData["cams"][camIndex]
    local secondCam = cachedData["cams"][secondCamIndex] or nil

    local InterpolateCams = function(cam1, cam2, duration)
        SetCamActive(cam1, true)
        SetCamActiveWithInterp(cam2, cam1, duration, true, true)
    end

    if secondCamIndex then
        InterpolateCams(cam, secondCam, camDuration or 5000)
    end
end

CheckIfInsideMotel = function()
    local exitPos = {}
    for k,v in pairs(Config.Houses) do
        for a,b in pairs(v) do   
            if a == "exit" then 
                exitPos[k] = b
            end
        end
    end
    for i=1, #exitPos do
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), exitPos[i]) <= 20.0 then 
            for k,v in pairs(Config.Houses) do 
                if k == i then 
                    for a,b in pairs(v) do 
                        if a == "pos" then 
                            SetEntityCoords(PlayerPedId(), b)
                            ESX.ShowNotification("Has aparecido en la puerta de tu casa.")
                        end
                    end
                end
            end
        end
    end

    --[[ 
    if insideMotel then
        Citizen.Wait(500)

        local ownedMotel
        for doorIndex, doorData in pairs(cachedData["houses"]) do
            for roomIndex, roomData in ipairs(doorData["rooms"]) do
            local roomData = roomData["motelData"]
            
            local allowed = roomData["displayLabel"] == ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]

                if allowed then
                    cachedData["cachedRoom"] = roomData

                    ownedMotel = roomData
                end
            end
        end

        if ownedMotel then
            EnterMotel(ownedMotel)
        else
            local garageCoords = vector3(-191.05, 6229.11, 32.0)
            Wait(3000)
            ESX.Game.Teleport(PlayerPedId(), garageCoords, function()
                ESX.ShowNotification("No eres dueño de este apartamento, fuera!.")
            end)
        end
    end
    ]]
end

RegisterNetEvent('mp:checkInHouse')
AddEventHandler('mp:checkInHouse', function()
    CheckIfInsideMotel()
end)

CreateBlip = function()
	for k,v in ipairs(Config.LandLord) do 
	    local pinkCageBlip = AddBlipForCoord(v.pos)

		SetBlipSprite(pinkCageBlip, 476)
		SetBlipScale(pinkCageBlip, 0.9)
		SetBlipColour(pinkCageBlip, 4)
		SetBlipAsShortRange(pinkCageBlip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Inmobiliaria")
	    EndTextCommandSetBlipName(pinkCageBlip)
	end
    
    local megaMallBlip = AddBlipForCoord(2747.9279785156, 3472.796875, 55.673221588135)

	SetBlipSprite(megaMallBlip, 407)
	SetBlipScale(megaMallBlip, 1.1)
	SetBlipColour(megaMallBlip, 26)
	SetBlipAsShortRange(megaMallBlip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("IKEA - Muebles y decoración")
    EndTextCommandSetBlipName(megaMallBlip)
end

FadeOut = function(duration)
    DoScreenFadeOut(duration)

    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end
end

FadeIn = function(duration)
    DoScreenFadeIn(duration)

    while not IsScreenFadedIn() do
        Citizen.Wait(0)
    end
end

WaitForModel = function(model)
    if not IsModelValid(model) then
        --ESX.ShowNotification("Este modelo no existe.")

        return false
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)
    end
    
    return true
end