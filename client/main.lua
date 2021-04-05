ESX = nil

cachedData = {
	["houses"] = {},
	["storages"] = {},
	["furnishings"] = {},
	["keys"] = {}
}

Citizen.CreateThread(function()
	while not ESX do
		--Fetching esx library, due to new to esx using this.

		TriggerEvent("esx:getSharedObject", function(library) 
			ESX = library 
		end)

		Citizen.Wait(25)
	end

	if ESX.IsPlayerLoaded() then
		Init()
	end

	AddTextEntry("furnishing_instructions", Config.HelpTextMessage)
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
	ESX.PlayerData = playerData

	Init()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
	ESX.PlayerData["job"] = newJob
end)

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then return end

	RemoveSpawnedProps()
end)

RegisterNetEvent("james_motels:eventHandler")
AddEventHandler("james_motels:eventHandler", function(event, eventData)
	if event == "update_motels" then
		cachedData["houses"] = eventData
	elseif event == "update_storages" then
		cachedData["storages"][eventData["storageId"]] = eventData["newTable"]

		if ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "main_storage_menu_" .. eventData["storageId"]) then
			local openedMenu = ESX.UI.Menu.GetOpened("default", GetCurrentResourceName(), "main_storage_menu_" .. eventData["storageId"])

			if openedMenu then
				openedMenu.close()

				OpenStorage(eventData["storageId"])
			end
		end
	elseif event == "invite_player" then
		if eventData["player"]["source"] == GetPlayerServerId(PlayerId()) then
			Citizen.CreateThread(function()
				local startedInvite = GetGameTimer()

				cachedData["invited"] = true

				while GetGameTimer() - startedInvite < 7500 do
					Citizen.Wait(0)

					ESX.ShowHelpNotification("Has sido invitado al apartamento: " .. eventData["house"]["room"] .. ". ~INPUT_DETONATE~ para entrar.")

					if IsControlJustPressed(0, 47) then
						EnterMotel(eventData["house"])

						break
					end
				end

				cachedData["invited"] = false
			end)
		end
	elseif event == "knock_motel" then
		local currentInstance = DecorGetInt(PlayerPedId(), "currentInstance")

		if currentInstance and currentInstance == eventData["uniqueId"] then
			ESX.ShowNotification("Alguien está picando afuera.")
		end
	elseif event == "update_furnishing" then
		local currentInstance = DecorGetInt(PlayerPedId(), "currentInstance")

		--table.insert(cachedData["furnishings"][eventData["houseId"]]["furnishing"], eventData["furnishingData"])
		print("---- "..eventData["houseId"])
		print(currentInstance)
		if eventData["houseId"] == 0 then 
			eventData["houseId"] = currentInstance
		end
		if not cachedData["furnishings"] then 
			cachedData["furnishings"] = {}
		end
		if not cachedData["furnishings"][eventData["houseId"]] then 
			cachedData["furnishings"][eventData["houseId"]] = {}
		end
		if not cachedData["furnishings"][eventData["houseId"]]["furnishing"] then 
			cachedData["furnishings"][eventData["houseId"]]["furnishing"] = {} 
		end
		cachedData["furnishings"][eventData["houseId"]]["furnishing"] = eventData["furnishingData"]

		if currentInstance == eventData["houseId"] then
			SpawnFurnishing(currentInstance)
		end
	elseif event == "update_owned_furnishing" then
		ESX.TriggerServerCallback("mp_houses:getIdentifier", function(identifier)
			if not cachedData["furnishings"][identifier] then cachedData["furnishings"][identifier] = {} end

			cachedData["furnishings"][identifier]["ownedFurnishing"] = eventData["newData"]
		end)
	else
		-- print("Wrong event handler.")
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		if IsControlJustPressed(0, 344) then
			ShowKeyMenu()
		end
	end
end)

Citizen.CreateThread(function()

	cachedData["lastCheck"] = GetGameTimer() - 4750

	CreateBlip()

	while true do
		Citizen.Wait(0)
		local sleepThread = 0

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		local yourMotel

		for doorIndex, doorData in pairs(cachedData["houses"]) do
		    for roomIndex, roomData in ipairs(doorData["rooms"]) do
	        local roomData = roomData["motelData"]
		    
	        local allowed = roomData["displayLabel"] == ESX.PlayerData["character"]["firstname"] .. " " .. ESX.PlayerData["character"]["lastname"]

		        if allowed then
		            cachedData["cachedRoom"] = roomData

		            yourMotel = roomData
		        end
		    end
		end

		for motelRoom, motelData in pairs(Config.Houses) do
			local playerRoom = yourMotel and (yourMotel["room"] == motelData.name)

			local dstCheck = #(pedCoords - motelData.pos)
			local dstRange = 3.0 --or playerRoom and 35.0

			if dstCheck <= dstRange then
				sleepThread = 5 

				DrawScriptMarker({
					["type"] = 2,
					["pos"] = motelData.pos,
					["r"] = 100,
					["g"] = 100,
					["b"] = 0,
					["sizeX"] = 0.3,
					["sizeY"] = 0.3,
					["sizeZ"] = 0.3,
					["rotate"] = true
				})

				if dstCheck <= 0.8 then
					local displayText = "[~g~E~s~] Puerta: " .. motelData.name

					if IsControlJustPressed(0, 38) then
						OpenMotelRoomMenu(motelData.name)
					end

					DrawScriptText(motelData.pos + vector3(0.0, 0.0, 0.5), displayText)
				end
			end
		end

		for LandLordIndex, LandLordData in ipairs(Config.LandLord) do

			local dstCheck = #(pedCoords - LandLordData.pos)

			if dstCheck <= 3.0 then
				sleepThread = 5

				local displayText = "Inmobiliaria"

				if dstCheck <= 0.9 then
					displayText = "[~g~E~s~] " .. displayText

					if IsControlJustPressed(0, 38) then
						OpenLandLord(LandLordData.data)
					end
				end

				DrawScriptText(LandLordData.pos, displayText)
			end
		end
	end
end)